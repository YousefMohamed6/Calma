import 'package:calmaa/common/controller/base_controller.dart';
import 'package:calmaa/common/manager/logger.dart';
import 'package:calmaa/common/service/api/post_service.dart';
import 'package:calmaa/model/post_story/post/explore_page_model.dart';
import 'package:calmaa/model/post_story/post_model.dart';
import 'package:calmaa/screen/hashtag_screen/hashtag_screen.dart';
import 'package:calmaa/screen/post_screen/single_post_screen.dart';
import 'package:calmaa/screen/reels_screen/reels_screen.dart';
import 'package:calmaa/screen/scan_qr_code_screen/scan_qr_code_screen.dart';
import 'package:calmaa/screen/video_player_screen/video_player_screen.dart';
import 'package:get/get.dart';

class ExploreScreenController extends BaseController {
  Rx<ExplorePageData?> explorePageData = Rx(null);

  @override
  void onInit() {
    super.onInit();
    fetchExplorePageData();
  }

  Future<void> fetchExplorePageData() async {
    isLoading.value = true;
    explorePageData.value = await PostService.instance.fetchExplorePageData();
    isLoading.value = false;
  }

  void onExploreTap(String? hashtag) {
    Get.to(() => HashtagScreen(hashtag: hashtag ?? '', index: 0),
        preventDuplicates: false);
  }

  void onPostTap(Post post) {
    switch (post.postType) {
      case PostType.reel:
        Get.to(() => ReelsScreen(reels: [post].obs, position: 0));
        break;
      case PostType.image:
        Get.to(() => SinglePostScreen(post: post, isFromNotification: false));
        break;
      case PostType.video:
        Get.to(() => VideoPlayerScreen(post: post));
        break;
      case PostType.text:
        break;
      case PostType.none:
        Loggers.error('Post Type none');
        break;
    }
  }

  void onScanQrCode() {
    Get.to(() => const ScanQrCodeScreen());
  }
}
