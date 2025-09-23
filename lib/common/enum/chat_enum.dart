import 'package:calmaa/utilities/asset_res.dart';
import 'package:calmaa/utilities/color_res.dart';
import 'package:calmaa/utilities/theme_res.dart';
import 'package:flutter/material.dart';

enum UserRequestAction {
  block,
  reject,
  accept;

  static const Map<UserRequestAction, String> titles = {
    UserRequestAction.block: 'block',
    UserRequestAction.reject: 'reject',
    UserRequestAction.accept: 'accept',
  };

  static Map<UserRequestAction, Color> colors(BuildContext context) => {
        UserRequestAction.block: bgGrey(context),
        UserRequestAction.reject: ColorRes.likeRed.withValues(alpha: .15),
        UserRequestAction.accept: ColorRes.green.withValues(alpha: .15),
      };

  static Map<UserRequestAction, Color> titleColors(BuildContext context) => {
        UserRequestAction.block: textDarkGrey(context),
        UserRequestAction.reject: ColorRes.likeRed,
        UserRequestAction.accept: ColorRes.green,
      };

  String get title => titles[this]!;

  Color color(BuildContext context) => colors(context)[this]!;

  Color titleColor(BuildContext context) => titleColors(context)[this]!;
}

enum ChatAction {
  gift,
  audio,
  sticker,
  media;

  String get image {
    switch (this) {
      case ChatAction.gift:
        return AssetRes.icGift_2;
      case ChatAction.audio:
        return AssetRes.icVoice;
      case ChatAction.sticker:
        return AssetRes.icSticker;
      case ChatAction.media:
        return AssetRes.icImage1;
    }
  }

  static List<ChatAction> getChatActions({required bool isGiphyEnabled}) {
    return ChatAction.values.where((action) {
      if (action == ChatAction.sticker && !isGiphyEnabled) return false;
      return true;
    }).toList();
  }
}
