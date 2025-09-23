import 'package:calmaa/utilities/theme_res.dart';
import 'package:flutter/material.dart';

class LoaderWidget extends StatelessWidget {
  final Color? color;

  const LoaderWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
            color: color ?? themeAccentSolid(context)));
  }
}
