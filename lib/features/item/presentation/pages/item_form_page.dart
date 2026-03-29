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
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  String? _selectedCategory;
  final List<String> categories = ItemCategory.values;
  bool get isEditing => widget.item != null;
  final _uuid = Uuid();
  File? _selectedImage;
  final _picker = ImagePicker();
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _nameFocus.addListener(() => setState(() {}));
    _descriptionFocus.addListener(() => setState(() {}));
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
      isShared: false,
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
            height: size.height * 0.4,
            margin: EdgeInsets.only(top: size.height * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nameTextfield(size),
                _descriptionTextfield(size),
                _categoryDropdown(size),
                SizedBox(height: size.height * 0.04),
                _imagePickerButton(size),
              ],
            ),
          ),
          _submitButton(size),
        ],
      ),
    ),
  );

  _nameTextfield(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, value, _) => TextFormField(
        controller: _nameController,
        focusNode: _nameFocus,
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
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey.shade300,
      ),
      onPressed: () => ImageSourceSelector.show(
        context,
        size: size,
        onImageSelected: (source) => _pickImage(source),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: size.width * 0.07, color: Colors.grey),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: _isUploadingImage
                ? SimpleWidgets.loader()
                : Text(
                    _selectedImage != null
                        ? _selectedImage!.path
                        : 'Subir imagen',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
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
            disabledBackgroundColor: Colors.grey,
            // textStyle: TextStyle()
            disabledForegroundColor: Colors.white,
            backgroundColor: _isUploadingImage ? Colors.grey : Colors.blue,
          ),
          onPressed: _isUploadingImage ? null : _submit,
          child: Text(isEditing ? ' Guardar cambios' : 'Subir producto'),
        ),
      );
    },
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

  void _uploadImage(File file) =>
      context.read<ItemBloc>().add(UploadItemImageEvent(file));

  _clearTextField(TextEditingController controller) => IconButton(
    icon: const Icon(Icons.close, size: 18),
    onPressed: () => controller.clear(),
  );
}
