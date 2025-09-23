import 'dart:ui';

import 'package:calmaa/utilities/text_style_custom.dart';
import 'package:calmaa/utilities/theme_res.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';

class CustomBlurButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomBlurButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: SmoothBorderRadius(cornerRadius: 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: SmoothBorderRadius(cornerRadius: 20),
                border: Border.all(
                    color: whitePure(context).withValues(alpha: .2))),
            child: Text(title,
                style:
                    TextStyleCustom.outFitLight300(color: whitePure(context))),
          ),
        ),
      ),
    );
  }
}
