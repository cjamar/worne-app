import 'package:flutter/material.dart';

class SimpleWidgets {
  static loader() => const Center(child: CircularProgressIndicator());

  static snackbar(BuildContext context, String message, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          // margin: EdgeInsets.all(15),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadiusGeometry.circular(20),
          // ),
        ),
      );

  static placeholderAvatar(Size size, IconData icon) =>
      Icon(icon, color: Colors.blueGrey, size: size.width * 0.07);

  static placeholderImage(Size size, IconData icon) => Center(
    child: Icon(icon, size: size.width * 0.15, color: Colors.grey.shade300),
  );

  static inputBorder(Size size, Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(size.width * 0.02),
    borderSide: BorderSide(color: color),
  );
}
