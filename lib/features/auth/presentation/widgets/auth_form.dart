import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class AuthForm extends StatefulWidget {
  final String buttonText;
  final bool showExtras;
  final bool isRegister;
  final void Function(String email, String password) onSubmit;

  const AuthForm({
    super.key,
    required this.buttonText,
    required this.onSubmit,
    this.showExtras = true,
    this.isRegister = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _isFormValid.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _emailTextField(size),
              SizedBox(height: size.height * 0.025),
              _passwordTextField(size),
              SizedBox(height: size.height * 0.025),
              if (widget.isRegister) ...[_confirmPasswordTextField(size)],

              if (widget.showExtras) _rememberAndForgotPassword(),
            ],
          ),

          SizedBox(height: size.height * 0.04),
          _submitButton(size),
        ],
      ),
    );
  }

  _emailTextField(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _emailController,
      builder: (context, value, _) => TextFormField(
        controller: _emailController,
        focusNode: _emailFocus,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Campo vacío' : null,
        decoration: InputDecoration(
          hintText: 'Email',
          filled: true,
          fillColor: Colors.white,
          border: _inputBorder(size, Colors.grey),
          enabledBorder: _inputBorder(size, Colors.grey),
          focusedBorder: _inputBorder(size, Colors.grey),
          suffixIcon: value.text.isNotEmpty && _emailFocus.hasFocus
              ? _clearTextField(_emailController)
              : null,
        ),
      ),
    ),
  );

  _passwordTextField(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _passwordController,
      builder: (context, value, _) => TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocus,
        obscureText: _obscurePassword,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Campo vacío' : null,
        decoration: InputDecoration(
          hintText: 'Contraseña',
          filled: true,
          fillColor: Colors.white,
          border: _inputBorder(size, Colors.grey),
          enabledBorder: _inputBorder(size, Colors.grey),
          focusedBorder: _inputBorder(size, Colors.grey),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.text.isNotEmpty && _passwordFocus.hasFocus)
                _clearTextField(_passwordController),
              _togglePasswordVisibility(),
            ],
          ),
        ),
      ),
    ),
  );

  _confirmPasswordTextField(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _confirmPasswordController,
      builder: (context, value, _) => TextFormField(
        controller: _confirmPasswordController,
        focusNode: _confirmPasswordFocus,
        obscureText: _obscurePassword,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obligatorio';
          }
          if (value != _passwordController.text) {
            return 'Las contraseñas no coinciden';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Confirmar contraseña',
          filled: true,
          fillColor: Colors.white,
          border: _inputBorder(size, Colors.grey),
          enabledBorder: _inputBorder(size, Colors.grey),
          focusedBorder: _inputBorder(size, Colors.grey),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.text.isNotEmpty && _confirmPasswordFocus.hasFocus)
                _clearTextField(_confirmPasswordController),
              _togglePasswordVisibility(),
            ],
          ),
        ),
      ),
    ),
  );

  _submitButton(Size size) => ValueListenableBuilder<bool>(
    valueListenable: _isFormValid,
    builder: (context, isValid, _) {
      return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

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
                backgroundColor: Colors.blue,
              ),
              onPressed: (isValid && !isLoading) ? _onSubmit : null,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.buttonText),
            ),
          );
        },
      );
    },
  );

  _rememberAndForgotPassword() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [_rememberMeCheck(), Text('¿Olvidaste la contraseña?')],
  );

  _rememberMeCheck() => Row(
    children: [
      Checkbox(
        value: rememberMe,
        onChanged: (value) => setState(() {
          rememberMe = value!;
        }),
        shape: RoundedRectangleBorder(),
      ),
      Text('Recordarme'),
    ],
  );

  void _onSubmit() {
    if (!_isFormValid.value) return;

    widget.onSubmit(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  void _validateForm() {
    final emailValid = _emailController.text.trim().isNotEmpty;
    final passwordValid = _passwordController.text.trim().isNotEmpty;

    final confirmValid =
        !widget.isRegister ||
        _confirmPasswordController.text.trim() ==
            _passwordController.text.trim();

    _isFormValid.value = emailValid && passwordValid && confirmValid;
  }

  InputBorder _inputBorder(Size size, Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(size.width * 0.02),
    borderSide: BorderSide(color: color),
  );

  Widget _clearTextField(TextEditingController controller) => IconButton(
    icon: const Icon(Icons.close, size: 18),
    onPressed: () => controller.clear(),
  );

  Widget _togglePasswordVisibility() => IconButton(
    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
    onPressed: () {
      setState(() {
        _obscurePassword = !_obscurePassword;
      });
    },
  );
}
