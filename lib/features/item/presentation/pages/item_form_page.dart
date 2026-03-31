import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item_category.dart';
import 'package:prestar_ropa_app/features/item/domain/entities/item_status.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_event.dart';
import 'package:prestar_ropa_app/features/item/presentation/bloc/item_state.dart';
import 'package:prestar_ropa_app/features/shared/widgets/image_selector.dart';
import 'package:prestar_ropa_app/features/shared/widgets/simple_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/item.dart';

class ItemFormPage extends StatefulWidget {
  final Item? item;
  const ItemFormPage({super.key, this.item});

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _userFocus = FocusNode();
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

    if (widget.item != null) {
      _nameController = TextEditingController(text: widget.item?.name);
      _descriptionController = TextEditingController(
        text: widget.item?.description,
      );
      _uploadedImageUrl = widget.item!.imageUrl;
    }

    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _emailController = TextEditingController();
    _nameFocus.addListener(() => setState(() {}));
    _descriptionFocus.addListener(() => setState(() {}));
    _userFocus.addListener(() => setState(() {}));
    _selectedCategory = widget.item?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
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
      }
      if (state is ImageUploadError) {
        setState(() {
          _isUploadingImage = false;
        });
        SimpleWidgets.snackbar(context, state.message);
      }
      if (state is ItemLoaded) {
        Navigator.pop(context);
      }
      if (state is ItemError) {
        SimpleWidgets.snackbar(context, state.message);
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

  _thumbnailImagePicker(Size size) =>
      widget.item != null && widget.item!.imageUrl.isNotEmpty
      ? CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(widget.item!.imageUrl),
        )
      : Icon(Icons.image, size: size.width * 0.07, color: Colors.grey);

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

  _submitButton(Size size) => BlocBuilder<ItemBloc, ItemState>(
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
          onPressed: _isUploadingImage || !_isOwner ? null : _submit,
          child: Text(isEditing ? ' Guardar cambios' : 'Subir producto'),
        ),
      );
    },
  );

  Future<void> _shareItemDialog(Size size) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Compartir item'),
        content: _userToShareTextfield(size),
        actions: [
          _textButtonDialog(
            size,
            'Cancelar',
            Colors.grey.shade400,
            Colors.black,
            false,
          ),
          _textButtonDialog(
            size,
            'Compartir',
            Colors.deepPurpleAccent,
            Colors.white,
            true,
          ),
        ],
      ),
    );
    if (confirmed == true) _shareItem(_emailController.text.trim());
  }

  _userToShareTextfield(Size size) => TextField(
    controller: _emailController,
    decoration: InputDecoration(hintText: 'Email del usuario'),
  );

  _textButtonDialog(
    Size size,
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

  _shareItem(String email) {
    context.read<ItemBloc>().add(
      ShareItemByEmailEvent(widget.item!.id!, email),
    );
    SimpleWidgets.snackbar(context, 'Compartiendo...');
  }

  _clearTextField(TextEditingController controller) => IconButton(
    icon: const Icon(Icons.close, size: 18),
    onPressed: () => controller.clear(),
  );
}
