import 'package:flutter/material.dart';
import 'package:prestar_ropa_app/core/theme/app_styles.dart';

class SimpleWidgets {
  static loader() =>
      Center(child: CircularProgressIndicator(color: AppStyles.primaryColor));

  static snackbar(BuildContext context, String message, Color color) =>
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));

  static placeholderAvatar(Size size, IconData icon) =>
      Icon(icon, color: Colors.blueGrey, size: size.width * 0.07);

  static placeholderImage(Size size, IconData icon) => Center(
    child: Icon(icon, size: size.width * 0.15, color: Colors.grey.shade300),
  );

  static containerWithIcon(Size size, IconData icon, String text) => Padding(
    padding: EdgeInsetsGeometry.only(bottom: size.height * 0.13),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: size.width * 0.2, color: Colors.grey.shade300),
          SizedBox(height: size.height * 0.02),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    ),
  );

  static inputBorder(Size size, Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(size.width * 0.02),
    borderSide: BorderSide(color: color),
  );
}
