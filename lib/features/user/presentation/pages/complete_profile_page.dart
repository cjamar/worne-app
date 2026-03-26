import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  final FocusNode _usernameFocus = FocusNode();
  final _picker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _usernameFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _completeProfileBody(size),
      ),
    );
  }

  _completeProfileBody(Size size) => Container(
    width: size.width,
    height: size.height,
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: size.width * 0.8,
            height: size.height * 0.5,
            color: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: size.height * 0.1,
                  color: Colors.orange,
                  child: Center(child: Text('Username textfield')),
                ),
                Container(
                  height: size.height * 0.3,
                  color: Colors.green,
                  child: Center(child: Text('Avatar image')),
                ),
              ],
            ),
          ),
          Container(
            width: size.width * 0.8,
            height: size.height * 0.1,
            color: Colors.blue,
            child: Center(child: Text('Submit button')),
          ),
        ],
      ),
    ),
  );
}
