import 'package:calmaa/utilities/asset_res.dart';
import 'package:flutter/material.dart';

class ThemeBlurBg extends StatelessWidget {
  const ThemeBlurBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetRes.icBackground,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
