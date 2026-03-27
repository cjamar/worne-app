import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prestar_ropa_app/features/user/domain/entities/user.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_event.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_state.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final _picker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    _usernameFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  _submit() {
    if (!_isFormValid.value) return;

    final userState = context.read<UserBloc>().state;

    if (userState is UserLoaded) {
      final updatedUser = userState.user.copyWith(
        username: _usernameController.text.trim(),
        avatarUrl: _uploadedImageUrl ?? userState.user.avatarUrl,
      );
      _updateUser(updatedUser);
    }
  }

  _validateForm() {
    final usernameValid = _usernameController.text.trim().isNotEmpty;
    _isFormValid.value = usernameValid;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Completa tu perfil'),
          elevation: 0,
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: _completeProfileBody(size),
      ),
    );
  }

  _completeProfileBody(Size size) => BlocListener<UserBloc, UserState>(
    listener: (context, state) {
      if (state is UserLoaded) {
        setState(() {
          _uploadedImageUrl = state.user.avatarUrl;
          _isUploadingImage = false;
        });
      }
      if (state is UserError) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    },
    child: _formBody(size),
  );

  _formBody(Size size) => SizedBox(
    width: size.width,
    height: size.height,
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: size.width * 0.8,
            height: size.height * 0.45,
            color: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_userNameTextfield(size), _imageUserArea(size)],
            ),
          ),
          _submitButton(size),
        ],
      ),
    ),
  );

  _userNameTextfield(Size size) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.06,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _usernameController,
      builder: (context, value, _) => TextFormField(
        controller: _usernameController,
        focusNode: _usernameFocus,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Campo vacío' : null,
        decoration: InputDecoration(
          hintText: 'Escribe tu nombre',
          filled: true,
          fillColor: Colors.white,
          border: _inputBorder(size, Colors.grey),
          enabledBorder: _inputBorder(size, Colors.grey),
          focusedBorder: _inputBorder(size, Colors.grey),
          errorBorder: _inputBorder(size, Colors.redAccent),
          suffixIcon: value.text.isNotEmpty && _usernameFocus.hasFocus
              ? _clearTextField(_usernameController)
              : null,
        ),
      ),
    ),
  );

  _imageUserArea(Size size) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.3,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_userAvatar(size), _imagePickerButton(size)],
    ),
  );

  _userAvatar(Size size) => SizedBox(
    height: size.height * 0.22,
    width: size.width,
    child: CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      backgroundImage: _uploadedImageUrl != null
          ? NetworkImage(
              '${_uploadedImageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
            )
          : null,
      // backgroundImage: _uploadedImageUrl != null
      //     ? NetworkImage(_uploadedImageUrl!)
      //     : null,
      child: _uploadedImageUrl == null
          ? Icon(
              Icons.person,
              size: size.width * 0.2,
              color: Colors.grey.shade400,
            )
          : null,
    ),
  );

  _imagePickerButton(Size size) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.05,
    child: ElevatedButton(
      onPressed: () => _showImageSourceSelector(size),
      child: _isUploadingImage
          ? _loader()
          : Text(
              _selectedImage != null
                  ? _selectedImage!.path
                  : 'Añadir foto de perfil',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
    ),
  );

  _showImageSourceSelector(Size size) async => showModalBottomSheet(
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
            ImageSource.camera,
          ),
          _pickImageSourceButton(
            size,
            Icons.photo_library,
            'Galería',
            ImageSource.gallery,
          ),
        ],
      ),
    ),
  );

  _pickImageSourceButton(
    Size size,
    IconData icon,
    String text,
    ImageSource source,
  ) => InkWell(
    onTap: () {
      Navigator.pop(context);
      _pickImage(source);
    },
    child: Container(
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
    ),
  );

  void _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);

    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        _selectedImage = file;
        _isUploadingImage = true;
      });
      _uploadImage(file);
    }
  }

  _submitButton(Size size) => ValueListenableBuilder<bool>(
    valueListenable: _isFormValid,
    builder: (context, isValid, _) => BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLoading = state is UserLoading;

        return SizedBox(
          width: size.width * 0.8,
          height: size.height * 0.05,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            onPressed: (isValid && !isLoading) ? _submit : null,
            child: isLoading ? _loader() : Text('Completar perfil'),
          ),
        );
      },
    ),
  );

  _uploadImage(File file) =>
      context.read<UserBloc>().add(UploadUserAvatarEvent(file));

  _updateUser(User updatedUser) =>
      context.read<UserBloc>().add(UpdateUserEvent(updatedUser));

  Widget _clearTextField(TextEditingController controller) => IconButton(
    icon: const Icon(Icons.close, size: 18),
    onPressed: () => controller.clear(),
  );

  InputBorder _inputBorder(Size size, Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(size.width * 0.02),
    borderSide: BorderSide(color: color),
  );

  _loader() => Center(child: CircularProgressIndicator());
}
