import 'package:flutter/material.dart';

class SimpleWidgets {
  static loader() => const Center(child: CircularProgressIndicator());

  static snackbar(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  static errorBrokenImage(Size size) => Center(
    child: Icon(
      Icons.broken_image,
      size: size.width * 0.15,
      color: Colors.grey.shade300,
    ),
  );

  static placeholderImage(Size size) => Center(
    child: Icon(
      Icons.image,
      size: size.width * 0.15,
      color: Colors.grey.shade300,
    ),
  );

  static inputBorder(Size size, Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(size.width * 0.02),
    borderSide: BorderSide(color: color),
  );
}
