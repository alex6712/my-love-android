import 'package:flutter/material.dart';

class ImageWithFallback extends StatelessWidget {
  final double size;

  const ImageWithFallback({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: size,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );
  }
}
