import 'package:calmaa/common/extensions/string_extension.dart';
import 'package:calmaa/common/widget/custom_divider.dart';
import 'package:calmaa/common/widget/custom_image.dart';
import 'package:calmaa/common/widget/text_button_custom.dart';
import 'package:calmaa/languages/languages_keys.dart';
import 'package:calmaa/model/livestream/app_user.dart';
import 'package:calmaa/model/user_model/user_model.dart';
import 'package:calmaa/utilities/text_style_custom.dart';
import 'package:calmaa/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveStreamJoinSheet extends StatelessWidget {
  final AppUser? hostUser;
  final User? myUser;
  final VoidCallback? onJoined;
  final VoidCallback? onCancel;

  const LiveStreamJoinSheet(
      {super.key, this.hostUser, this.myUser, this.onJoined, this.onCancel});

  @override
  Widget build(BuildContext context) {
    double imageSize = 100;
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: ShapeDecoration(
            shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                  top: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1)),
            ),
            color: scaffoldBackgroundColor(context),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const CustomDivider(width: 100),
                const SizedBox(height: 20),
                SizedBox(
                  height: imageSize,
                  width: imageSize * 2,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: CustomImage(
                              size: Size(imageSize, imageSize),
                              image: hostUser?.profile?.addBaseURL(),
                              fullName: hostUser?.fullname,
                              strokeWidth: 2,
                              strokeColor:
                                  whitePure(context).withValues(alpha: .55)),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: CustomImage(
                            size: Size(imageSize, imageSize),
                            image: myUser?.profilePhoto?.addBaseURL(),
                            fullName: myUser?.fullname ?? '',
                            strokeWidth: 2,
                            strokeColor:
                                whitePure(context).withValues(alpha: .55),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                      text: hostUser?.username,
                      style: TextStyleCustom.outFitSemiBold600(
                          color: textLightGrey(context), fontSize: 16),
                      children: [
                        TextSpan(
                            text: ' ${LKey.wantsYouToBeEtc.tr}',
                            style: TextStyleCustom.outFitRegular400(
                                color: textLightGrey(context), fontSize: 16)),
                      ]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: TextButtonCustom(
                        onTap: () {
                          Get.back();
                          onCancel?.call();
                        },
                        title: LKey.cancel.tr,
                        titleColor: textLightGrey(context),
                        backgroundColor: bgMediumGrey(context),
                        horizontalMargin: 0,
                      ),
                    ),
                    Expanded(
                      child: TextButtonCustom(
                        onTap: () {
                          Get.back();
                          onJoined?.call();
                        },
                        title: LKey.join.tr,
                        titleColor: whitePure(context),
                        backgroundColor: blueFollow(context),
                        horizontalMargin: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
