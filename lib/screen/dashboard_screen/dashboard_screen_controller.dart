import 'dart:async';

import 'package:calmaa/common/controller/ads_controller.dart';
import 'package:calmaa/common/controller/base_controller.dart';
import 'package:calmaa/common/controller/firebase_firestore_controller.dart';
import 'package:calmaa/common/manager/firebase_notification_manager.dart';
import 'package:calmaa/common/manager/logger.dart';
import 'package:calmaa/common/manager/session_manager.dart';
import 'package:calmaa/common/service/api/user_service.dart';
import 'package:calmaa/common/service/subscription/subscription_manager.dart';
import 'package:calmaa/common/service/video_cache_helper/video_cache_helper.dart';
import 'package:calmaa/common/widget/restart_widget.dart';
import 'package:calmaa/languages/languages_keys.dart';
import 'package:calmaa/model/chat/chat_thread.dart';
import 'package:calmaa/model/general/settings_model.dart';
import 'package:calmaa/model/user_model/user_model.dart';
import 'package:calmaa/screen/camera_screen/camera_screen.dart';
import 'package:calmaa/screen/feed_screen/feed_screen_controller.dart';
import 'package:calmaa/screen/gif_sheet/gif_sheet_controller.dart';
import 'package:calmaa/utilities/asset_res.dart';
import 'package:calmaa/utilities/firebase_const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class DashboardScreenController extends BaseController
    with GetSingleTickerProviderStateMixin {
  List<String> bottomIconList = [
    AssetRes.icReel,
    AssetRes.icPost,
    AssetRes.icLiveStream,
    AssetRes.icSearch,
    AssetRes.icChat,
    AssetRes.icProfile
  ];
  RxInt selectedPageIndex = 0.obs;
  RxDouble scaleValue = 1.0.obs;
  Function(int index)? onBottomIndexChanged;
  Rx<PostUploadingProgress> postProgress = Rx(PostUploadingProgress());
  Function(PostUploadingProgress progress) onProgress = (_) {};

  late AnimationController animationController;

  FirebaseFirestore db = FirebaseFirestore.instance;
  RxInt unReadCount = 0.obs;

  late StreamSubscription _unReadCountSubscription;
  late Animation<double> scaleAnimation;
  User? user = SessionManager.instance.getUser();

  @override
  void onInit() {
    super.onInit();
    Get.put(GifSheetController());
    animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    )..addListener(() {
        scaleValue.value = scaleAnimation.value; // Update reactive scale value
      });
    onProgress = (progress) {
      postProgress.value = progress;
    };
    Get.put(AdsController());
  }

  @override
  void onReady() async {
    super.onReady();
    SubscriptionManager.shared.subscriptionListener();

    // Run below in parallel
    _createZegoEngine();
    _fetchLanguageFromUser();
    _fetchUnReadCount();
    startCacheCleanupScheduler();
    _subscribeFollowUserIds();
  }

  void startCacheCleanupScheduler() {
    UserService.instance.updateLastUsedAt();
    VideoCacheHelper.clearAllCache();
    Timer.periodic(const Duration(minutes: 15), (_) {
      VideoCacheHelper.clearExpiredVideos();
      UserService.instance.updateLastUsedAt();
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    _unReadCountSubscription.cancel();
    VideoCacheHelper.clearAllCache();
    super.onClose();
  }

  onChanged(int index) {
    if (index == 1) {
      onFeedPostScrollDown(index);
    }
    if (selectedPageIndex.value == index) return;
    HapticFeedback.lightImpact();
    onBottomIndexChanged?.call(index);
    selectedPageIndex.value = index;
    animationController
      ..reset()
      ..forward();
  }

  onFeedPostScrollDown(int index) {
    if (selectedPageIndex.value != index) return;
    if (Get.isRegistered<FeedScreenController>()) {
      final controller = Get.find<FeedScreenController>();
      if (controller.posts.isNotEmpty && !controller.isLoading.value) {
        controller.postScrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 150), curve: Curves.linear);
        controller.refreshKey.currentState?.show();
      }
    }
  }

  void _fetchUnReadCount() {
    _unReadCountSubscription = db
        .collection(FirebaseConst.users)
        .doc(user?.id.toString())
        .collection(FirebaseConst.usersList)
        .where(FirebaseConst.isDeleted, isEqualTo: false)
        .withConverter(
            fromFirestore: (snapshot, options) =>
                ChatThread.fromJson(snapshot.data()!),
            toFirestore: (ChatThread value, options) => value.toJson())
        .snapshots()
        .listen((event) {
      final count =
          event.docs.where((doc) => (doc.data().msgCount ?? 0) > 0).length;
      unReadCount.value = count;
    });
  }

  Future<void> _createZegoEngine() async {
    Setting? appSetting = SessionManager.instance.getSettings();
    int appId = int.parse(appSetting?.zegoAppId ?? '0');
    if (appId == 0) {
      return Loggers.info('The Zego App ID is not configured.');
    }
    try {
      await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
          appId, ZegoScenario.Default,
          appSign: appSetting?.zegoAppSign));
    } on MissingPluginException catch (e) {
      Loggers.error('Create Zego Engine : ${e.message}');
    }
  }

  Future<void> _fetchLanguageFromUser() async {
    String savedLanguage = SessionManager.instance.getLang();
    String userLanguage = user?.appLanguage ?? 'en';
    if (userLanguage != savedLanguage) {
      SessionManager.instance.setLang(userLanguage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RestartWidget.restartApp(Get.context!);
      });
    }
  }

  void _subscribeFollowUserIds() async {
    Future.wait([addUserInFirebase()]);
    for (int id in (user?.followingIds ?? [])) {
      // Delay slightly to avoid overloading FCM
      await Future.delayed(const Duration(milliseconds: 100));
      Future.wait([
        FirebaseNotificationManager.instance.subscribeToTopic(topic: '$id')
      ]);
    }
  }

  Future addUserInFirebase() async {
    if (Get.isRegistered<FirebaseFirestoreController>()) {
      Get.find<FirebaseFirestoreController>().addUser(user);
    } else {
      Get.put(FirebaseFirestoreController()).addUser(user);
    }
  }
}

class PostUploadingProgress {
  final CameraScreenType type;
  final UploadType uploadType;
  final double progress;

  PostUploadingProgress(
      {this.type = CameraScreenType.post,
      this.progress = 0,
      this.uploadType = UploadType.none});
}

enum UploadType {
  none,
  finish,
  error,
  uploading;

  String title(CameraScreenType type) {
    switch (this) {
      case UploadType.none:
        return '';
      case UploadType.finish:
        return type == CameraScreenType.post
            ? LKey.postUploadSuccessfully.tr
            : LKey.storyUploadSuccess.tr;
      case UploadType.error:
        return LKey.uploadingFailed.tr;
      case UploadType.uploading:
        return type == CameraScreenType.post
            ? LKey.postIsBeginUploading.tr
            : LKey.storyIsBeginUploading.tr;
    }
  }
}
