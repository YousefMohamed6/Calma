import 'package:calmaa/common/controller/base_controller.dart';
import 'package:calmaa/common/functions/debounce_action.dart';
import 'package:calmaa/common/manager/firebase_notification_manager.dart';
import 'package:calmaa/common/manager/haptic_manager.dart';
import 'package:calmaa/common/manager/logger.dart';
import 'package:calmaa/common/manager/session_manager.dart';
import 'package:calmaa/common/service/api/gift_wallet_service.dart';
import 'package:calmaa/languages/languages_keys.dart';
import 'package:calmaa/model/general/settings_model.dart';
import 'package:calmaa/model/livestream/app_user.dart';
import 'package:calmaa/model/post_story/post_model.dart';
import 'package:calmaa/model/user_model/user_model.dart';
import 'package:calmaa/screen/gift_sheet/send_gift_dialog.dart';
import 'package:calmaa/screen/gift_sheet/send_gift_sheet.dart';
import 'package:calmaa/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendGiftSheetController extends BaseController {
  Rx<Setting?> settings = Rx<Setting?>(null);
  Rx<User?> myUser = Rx<User?>(null);
  int? userId;
  List<AppUser> liveUsers;
  GiftType? giftType;
  late LivestreamScreenController livestreamController;

  SendGiftSheetController(this.giftType, this.userId, this.liveUsers);

  @override
  void onInit() {
    super.onInit();
    _initData();

    if (liveUsers.isNotEmpty &&
        (giftType == GiftType.livestream || giftType == GiftType.battle)) {
      livestreamController = Get.find<LivestreamScreenController>();
      if (livestreamController.selectedGiftUser.value == null) {
        livestreamController.selectedGiftUser = liveUsers.first.obs;
      } else {
        DebounceAction.shared.call(() {
          livestreamController.selectedGiftUser.value = liveUsers.firstWhere(
              (element) =>
                  element.userId ==
                  livestreamController.selectedGiftUser.value?.userId,
              orElse: () => liveUsers.first);
        });
      }
    }
  }

  _initData() {
    settings.value = SessionManager.instance.getSettings();
    myUser.value = SessionManager.instance.getUser();
  }

  void onGiftTap(Gift gift, BuildContext context) {
    if (gift.id == null) {
      return showSnackBar('Gift Not Found');
    }

    if ((gift.coinPrice ?? 0) >= (myUser.value?.coinWallet ?? 0)) {
      return showSnackBar('Insufficient fund');
    }

    sendGift(gift, context);
  }

  Future<void> sendGift(Gift gift, BuildContext context) async {
    final giftId = gift.id?.toInt() ?? -1;

    final coinPrice = gift.coinPrice ?? 0;
    userId ??= livestreamController.selectedGiftUser.value?.userId;

    if (giftId == -1 || userId == -1) {
      return Loggers.error('Invalid Gift: $giftId or User: $userId');
    }

    if (coinPrice <= 0) {
      return Loggers.error(
          'Invalid coin price: $coinPrice, skipping gift sending.');
    }
    showLoader();
    final response = await GiftWalletService.instance
        .sendGift(giftId: giftId, userId: userId);
    stopLoader();
    if (response.status == true) {
      // Deduct gift coins from user wallet
      myUser.update((val) {
        val?.removeCoinFromWallet(coinPrice);
      });
      Loggers.info(myUser.value?.coinWallet);
      SessionManager.instance.setUser(myUser.value);
      if (giftType == GiftType.none) {
        Get.back(result: GiftManager(gift));
      } else {
        Get.back(
            result: GiftManager(gift,
                streamUser: livestreamController.selectedGiftUser.value));
      }
    } else {
      showSnackBar(response.message);
    }
  }
}

class GiftManager {
  Gift gift;
  AppUser? streamUser;

  GiftManager(this.gift, {this.streamUser});

  static Future<void> openGiftSheet(
      {int? userId,
      Post? post,
      GiftType giftType = GiftType.none,
      BattleView battleViewType = BattleView.red,
      List<AppUser> streamUsers = const [],
      required Function(GiftManager giftManager) onCompletion}) async {
    await Get.bottomSheet<GiftManager>(
      SendGiftSheet(
        userId: userId,
        giftType: giftType,
        battleViewType: battleViewType,
        streamUsers: streamUsers,
      ),
      isScrollControlled: true,
    ).then((gift) {
      if (gift != null) {
        onCompletion(gift);
      }
    });
  }

  static void showAnimationDialog(Gift gift) {
    showGeneralDialog(
      context: Get.context!,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SendGiftDialog(gift: gift);
      },
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation);

        if (slideAnimation.isForwardOrCompleted) {
          HapticManager.shared.light();
        }

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  static void sendNotification(Post? post) {
    final user = post?.user;
    if (user == null || user.id == SessionManager.instance.getUserID()) return;

    if (user.notifyGiftReceived == 1) {
      FirebaseNotificationManager.instance.sendLocalisationNotification(
        LKey.activitySentGift,
        type: NotificationType.post,
        deviceType: user.device,
        deviceToken: user.deviceToken,
        languageCode: user.appLanguage,
        body: NotificationInfo(id: post?.id),
      );
    }
  }
}
