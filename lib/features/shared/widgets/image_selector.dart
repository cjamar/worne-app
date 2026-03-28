import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSelector {
  static Future<void> show(
    BuildContext context, {
    required Size size,
    required Function(ImageSource) onImageSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        color: Colors.white,
        width: size.width,
        height: size.height * 0.4,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pickImageSourceButton(
              size,
              Icons.camera_alt,
              'Cámara',
              onImageSelected,
              context,
            ),
            _pickImageSourceButton(
              size,
              Icons.photo_library,
              'Galería',
              onImageSelected,
              context,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pickImageSourceButton(
    Size size,
    IconData icon,
    String text,
    Function(ImageSource) onImageSelected,
    BuildContext context,
  ) => InkWell(
    onTap: () {
      Navigator.pop(context);
      onImageSelected(
        icon == Icons.camera_alt ? ImageSource.camera : ImageSource.gallery,
      );
    },
    child: _bodyImageSourceButton(size, icon, text),
  );

  static Widget? _bodyImageSourceButton(
    Size size,
    IconData icon,
    String text,
  ) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: size.width * 0.1,
      vertical: size.width * 0.09,
    ),
    color: Colors.grey.shade200,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size.width * 0.1),
        SizedBox(height: size.height * 0.01),
        Text(text),
      ],
    ),
  );
}
