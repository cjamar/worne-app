import 'package:flutter/material.dart';

class RemoveItemModal {
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
  }) {
    final Size size = MediaQuery.of(context).size;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
        title: Text(title),
        content: Text(content),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          _textButtonDialog(
            size,
            context,
            'Cancelar',
            Colors.grey.shade300,
            Colors.black,
            false,
          ),
          _textButtonDialog(
            size,
            context,
            confirmText,
            Colors.redAccent,
            Colors.white,
            true,
          ),
        ],
      ),
    );
  }

  static _textButtonDialog(
    Size size,
    BuildContext context,
    String action,
    Color backgroundColor,
    Color foregroundColor,
    bool confirmButton,
  ) => TextButton(
    onPressed: () => Navigator.pop(context, confirmButton),
    style: TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(size.width * 0.06),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    ),
    child: Text(action),
  );
}
