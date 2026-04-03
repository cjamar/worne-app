import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/users_helper.dart';
import '../../../shared/widgets/image_selector.dart';
import '../../../shared/widgets/simple_widgets.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/item_category.dart';
import '../../domain/entities/item_status.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';
import '../bloc/item_state.dart';

class ItemFormPage extends StatefulWidget {
  final Item? item;
  const ItemFormPage({super.key, this.item});

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _modalShareFormKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);
  final ValueNotifier<bool> _isShareFormValid = ValueNotifier(false);
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  String? _selectedCategory;
  final List<String> categories = ItemCategory.values;
  bool get isEditing => widget.item != null;
  final _uuid = Uuid();
  File? _selectedImage;
  final _picker = ImagePicker();
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  late final String _currentUserId;
  late final bool _isOwner;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser!.id;
    _isOwner = widget.item == null || widget.item!.ownerId == _currentUserId;

    if (widget.item != null) _uploadedImageUrl = widget.item!.imageUrl;

    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _emailController = TextEditingController();

    _nameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
    _emailController.addListener(_shareModalValidateForm);

    _nameFocus.addListener(() => setState(() {}));
    _descriptionFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _selectedCategory = widget.item?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _isFormValid.dispose();
    _isShareFormValid.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_isFormValid.value) return;
    if (!_formKey.currentState!.validate()) return;

    final userId = Supabase.instance.client.auth.currentUser!.id;

    final item = Item(
      id: isEditing ? widget.item!.id : _uuid.v4(),
      ownerId: userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _uploadedImageUrl ?? widget.item?.imageUrl ?? '',
      category: _selectedCategory!,
      status: ItemStatus.available,
    );

    if (isEditing) {
      context.read<ItemBloc>().add(EditItem(item));
    } else {
      context.read<ItemBloc>().add(AddItem(item));
    }
  }

  _validateForm() {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final descriptionValid = _descriptionController.text.trim().isNotEmpty;
    _isFormValid.value = nameValid && descriptionValid;
  }

  _shareModalValidateForm() =>
      _isShareFormValid.value = _emailController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(isEditing ? 'Editar item' : 'Nuevo item'),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: _formPageBody(size),
      ),
    );
  }

  _formPageBody(Size size) => BlocListener<ItemBloc, ItemState>(
    listener: (context, state) {
      if (state is ImageUploaded) {
        setState(() {
          _uploadedImageUrl = state.imageUrl;
          _isUploadingImage = false;
        });
        _validateForm();
      }
      if (state is ImageUploadError) {
        setState(() {
          _isUploadingImage = false;
        });
        SimpleWidgets.snackbar(context, state.message, Colors.red);
      }
      if (state is ItemLoadedGrouped) {
        Navigator.pop(context);
      }
      if (state is ItemSharedSuccess) {
        SimpleWidgets.snackbar(context, state.message, Colors.blue);
        //  _clearItemState();
      }
      if (state is ItemError) {
        SimpleWidgets.snackbar(context, state.message, Colors.red);
      }
    },
    child: _itemFormBody(size),
  );

  _itemFormBody(Size size) => SizedBox(
    width: size.width,
    height: size.height * 0.75,
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: size.width,
            height: size.height * 0.5,
            margin: EdgeInsets.only(top: size.height * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _isSharedItemBanner(size),
                _nameTextfield(size),
                _descriptionTextfield(size),
                _categoryDropdown(size),
                SizedBox(height: size.height * 0.04),
                _imagePickerButton(size),
                _shareItemButton(size),
              ],
            ),
          ),
          _submitButton(size),
        ],
      ),
    ),
  );

  _isSharedItemBanner(Size size) => _isOwner
      ? SizedBox()
      : Container(
          width: double.infinity,
          padding: EdgeInsets.all(size.width * 0.03),
          color: Color(0xffe3b5ff),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Este item está compartido contigo',
                textAlign: TextAlign.center,
              ),
              Icon(Icons.handshake, size: size.width * 0.1),
            ],
          ),
        );

  _nameTextfield(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, value, _) => TextFormField(
        controller: _nameController,
        focusNode: _nameFocus,
        enabled: _isOwner,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Campo vacío' : null,
        decoration: InputDecoration(
          hintText: 'Nombre',
          filled: true,
          fillColor: Colors.white,
          border: SimpleWidgets.inputBorder(size, Colors.grey),
          enabledBorder: SimpleWidgets.inputBorder(size, Colors.grey),
          focusedBorder: SimpleWidgets.inputBorder(size, Colors.grey),
          errorBorder: SimpleWidgets.inputBorder(size, Colors.redAccent),
          suffixIcon: value.text.isNotEmpty && _nameFocus.hasFocus
              ? _clearTextField(_nameController)
              : null,
        ),
      ),
    ),
  );

  _descriptionTextfield(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _descriptionController,
      builder: (context, value, _) => TextFormField(
        controller: _descriptionController,
        focusNode: _descriptionFocus,
        enabled: _isOwner,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Campo vacío' : null,
        decoration: InputDecoration(
          hintText: 'Descripción',
          filled: true,
          fillColor: Colors.white,
          border: SimpleWidgets.inputBorder(size, Colors.grey),
          enabledBorder: SimpleWidgets.inputBorder(size, Colors.grey),
          focusedBorder: SimpleWidgets.inputBorder(size, Colors.grey),
          suffixIcon: value.text.isNotEmpty && _descriptionFocus.hasFocus
              ? _clearTextField(_descriptionController)
              : null,
        ),
      ),
    ),
  );

  _categoryDropdown(Size size) => SizedBox(
    width: size.width * 0.8,
    child: IgnorePointer(
      ignoring: !_isOwner,
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: const InputDecoration(labelText: 'Categoría'),
        items: categories
            .map(
              (category) =>
                  DropdownMenuItem(value: category, child: Text(category)),
            )
            .toList(),
        onChanged: (value) => setState(() {
          _selectedCategory = value;
        }),
        validator: (value) => value == null ? 'Selecciona una categoria' : null,
      ),
    ),
  );

  _imagePickerButton(Size size) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.06,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: _isOwner ? Colors.black : Colors.grey,
        backgroundColor: Colors.grey.shade300,
      ),
      onPressed: () => _isOwner
          ? ImageSourceSelector.show(
              context,
              size: size,
              onImageSelected: (source) => _pickImage(source),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _thumbnailImagePicker(size),
          SizedBox(width: size.width * 0.02),
          _textImagePicker(size),
        ],
      ),
    ),
  );

  _thumbnailImagePicker(Size size) {
    final imageUrl = _uploadedImageUrl ?? widget.item?.imageUrl ?? '';
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return Icon(Icons.image, size: size.width * 0.07, color: Colors.grey);
  }

  _textImagePicker(Size siz) => Expanded(
    child: _isUploadingImage
        ? SimpleWidgets.loader()
        : Text(
            _selectedImage != null
                ? _selectedImage!.path
                : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                ? 'Imagen actual'
                : 'Añadir imagen',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.end,
          ),
  );

  _shareItemButton(Size size) => SizedBox(
    width: size.width * 0.8,
    height: size.height * 0.06,
    child: Visibility(
      visible: _isOwner,
      child: ElevatedButton.icon(
        onPressed: () => _shareItemDialog(size),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Color(0xffe3b5ff),
        ),
        icon: Icon(Icons.handshake, size: 30),
        label: Text('Compartir'),
      ),
    ),
  );

  _submitButton(Size size) => ValueListenableBuilder<bool>(
    valueListenable: _isFormValid,
    builder: (context, isValid, child) => BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return SimpleWidgets.loader();
        }
        return SizedBox(
          width: size.width * 0.8,
          height: size.height * 0.06,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              // textStyle: TextStyle()
              disabledForegroundColor: Colors.white,
              backgroundColor: _isUploadingImage
                  ? Colors.grey.shade300
                  : Colors.blue,
            ),
            onPressed: (isValid && !_isUploadingImage && _isOwner)
                ? _submit
                : null,
            child: Text(isEditing ? ' Guardar cambios' : 'Subir producto'),
          ),
        );
      },
    ),
  );

  Future<void> _shareItemDialog(Size size) async {
    final email = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _shareItemModalBottom(context, size),
    );
    if (email != null && widget.item != null) {
      _shareItem(email);
    }
  }

  _shareItemModalBottom(BuildContext context, Size size) => Padding(
    padding: EdgeInsetsGeometry.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Container(
      color: Colors.white,
      height: size.height * 0.4,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Form(
        key: _modalShareFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text('Comparte tu producto con otro usuario'),
                SizedBox(height: size.height * 0.025),
                _userToShareTextfield(size),
              ],
            ),
            _textfieldAndButtonsModal(size),
          ],
        ),
      ),
    ),
  );

  _textfieldAndButtonsModal(Size size) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: MainAxisSize.max,
    children: [
      _userToShareButton(
        size,
        'Cancelar',
        Colors.grey.shade200,
        Colors.black,
        false,
      ),
      _userToShareButton(
        size,
        'Compartir',
        Colors.deepPurpleAccent,
        Colors.white,
        true,
      ),
    ],
  );

  _userToShareTextfield(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _emailController,
      builder: (context, value, _) => TextFormField(
        controller: _emailController,
        focusNode: _emailFocus,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Campo vacío';
          if (!UsersHelper.isValidEmail(value.trim())) return 'Email inválido';
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Email del usuario',
          filled: true,
          fillColor: Colors.white,
          border: SimpleWidgets.inputBorder(size, Colors.grey),
          enabledBorder: SimpleWidgets.inputBorder(size, Colors.grey),
          focusedBorder: SimpleWidgets.inputBorder(size, Colors.grey),
          suffixIcon: value.text.isNotEmpty && _emailFocus.hasFocus
              ? _clearTextField(_emailController)
              : null,
        ),
      ),
    ),
  );

  _userToShareButton(
    Size size,
    String action,
    Color backgroundColor,
    Color foregroundColor,
    bool confirmButton,
  ) => ValueListenableBuilder<bool>(
    valueListenable: _isShareFormValid,
    builder: (context, isValid, _) => SizedBox(
      height: size.height * 0.05,
      width: size.width * 0.4,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey,
        ),
        onPressed: (confirmButton && !isValid)
            ? null
            : () {
                if (confirmButton) {
                  if (!_modalShareFormKey.currentState!.validate()) return;
                }
                final email = _emailController.text.trim();
                _emailController.clear();
                Navigator.pop(context, confirmButton ? email : null);
              },
        child: Text(action),
      ),
    ),
  );

  Future<void> _pickImage(ImageSource source) async {
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

  _uploadImage(File file) =>
      context.read<ItemBloc>().add(UploadItemImageEvent(file));

  _shareItem(String email) async {
    try {
      await context.read<ItemBloc>().shareItemToUserByEmail(
        widget.item!.id!,
        email,
      );
      if (!mounted) return;
      _snackbarShareItemSuccess(email);
    } catch (e) {
      if (!mounted) return;
      _snackbarShareItemError(e);
    }
  }

  _snackbarShareItemSuccess(String email) => SimpleWidgets.snackbar(
    context,
    'Item compartido correctamente con $email',
    Colors.blue,
  );

  _snackbarShareItemError(Object e) => SimpleWidgets.snackbar(
    context,
    'Error al compartir item : ${e.toString()}',
    Colors.red,
  );

  _clearTextField(TextEditingController controller) => IconButton(
    icon: const Icon(Icons.close, size: 18),
    onPressed: () => controller.clear(),
  );
}
