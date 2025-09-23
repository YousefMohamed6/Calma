import 'package:calmaa/common/controller/base_controller.dart';
import 'package:calmaa/common/manager/session_manager.dart';
import 'package:calmaa/model/general/settings_model.dart';
import 'package:calmaa/screen/auth_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreenController extends BaseController {
  PageController pageController = PageController();
  RxInt selectedPage = RxInt(0);

  RxList<OnBoarding> onBoardingData = <OnBoarding>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchOnBoarding();
  }

  void _fetchOnBoarding() {
    for (var element
        in (SessionManager.instance.getSettings()?.onBoarding ?? [])) {
      onBoardingData.add(element);
    }
  }

  void onPageChanged(int value) {
    selectedPage.value = value;
  }

  void onNextTap() {
    if (selectedPage.value < onBoardingData.length - 1) {
      selectedPage.value++;
      pageController.animateToPage(
        selectedPage.value,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
      );
    } else if (selectedPage.value == onBoardingData.length - 1) {
      Get.off(() => const LoginScreen());
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
