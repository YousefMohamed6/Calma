import 'package:calmaa/model/chat/chat_thread.dart';
import 'package:calmaa/model/user_model/user_model.dart';
import 'package:calmaa/screen/chat_screen/chat_screen_controller.dart';
import 'package:calmaa/screen/chat_screen/widget/chat_bottom_action_view.dart';
import 'package:calmaa/screen/chat_screen/widget/chat_center_message_view.dart';
import 'package:calmaa/screen/chat_screen/widget/chat_top_profile_view.dart';
import 'package:calmaa/utilities/theme_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  final ChatThread conversationUser;
  final User? user;

  const ChatScreen({super.key, required this.conversationUser, this.user});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatScreenController(conversationUser.obs),
        tag: '${conversationUser.conversationId}');
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatTopProfileView(controller: controller),
          ChatMessageView(controller: controller),
          ChatBottomActionView(controller: controller)
        ],
      ),
    );
  }
}
