import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(body: _loginBody(size));
  }

  _loginBody(Size size) => SizedBox(
    width: size.width,
    height: size.height,
    child: Column(children: [_logoArea(size), _formArea(size)]),
  );

  _logoArea(Size size) => Container(
    width: size.width,
    height: size.height * 0.4,
    color: Colors.black87,
    child: Center(
      child: Container(
        width: size.width * 0.45,
        height: size.height * 0.08,
        color: Colors.white54,
        child: Center(child: Text('Logo')),
      ),
    ),
  );

  _formArea(Size size) => Container(
    width: size.width,
    height: size.height * 0.6,
    color: Colors.white,
    child: Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_formBody(size), _formButtons(size)],
    ),
  );

  _formBody(Size size) => Container(
    color: Colors.white24,
    width: size.width,
    height: size.height * 0.35,
    child: Form(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _emailTextField(size),
          _passwordTextField(size),
          _rememberAndForgotPassword(size),
          _loginButton(size),
        ],
      ),
    ),
  );

  _emailTextField(Size size) => SizedBox(
    width: size.width * 0.8,
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _emailController,
      builder: (context, value, _) => TextFormField(
        controller: _emailController,
        focusNode: _emailFocus,
        // style: TextStyle(),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Error, campo vacío' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: _inputBorder(size, Colors.red),
          enabledBorder: _inputBorder(size, Colors.grey),
          focusedBorder: _inputBorder(size, Colors.grey),
          focusedErrorBorder: _inputBorder(size, Colors.red),
          hintText: 'Email',
          // hintStyle: TextStyle(),
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
        // style: TextStyle(),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Error, campo vacío' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: _inputBorder(size, Colors.red),
          enabledBorder: _inputBorder(size, Colors.grey),
          focusedBorder: _inputBorder(size, Colors.grey),
          focusedErrorBorder: _inputBorder(size, Colors.red),
          hintText: 'Contraseña',
          // hintStyle: TextStyle(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.text.isNotEmpty && _passwordFocus.hasFocus)
                _clearTextField(_passwordController),
              _obscureTextIconButton(),
            ],
          ),
        ),
      ),
    ),
  );

  _rememberAndForgotPassword(Size size) => SizedBox(
    width: size.width * 0.85,
    // color: Colors.blue,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_rememberMeCheck(size), _forgotPasswordButton(size)],
    ),
  );

  _rememberMeCheck(Size size) => Row(
    children: [
      Checkbox(value: false, onChanged: (value) {}),
      Text('Recordarme'),
    ],
  );

  _forgotPasswordButton(Size size) => TextButton(
    onPressed: () {},
    child: Text(
      '¿Olvidaste la contraseña?',
      style: TextStyle(fontSize: 12, decoration: TextDecoration.underline),
    ),
  );

  _formButtons(Size size) => Container(
    color: Colors.black26,
    width: size.width,
    height: size.height * 0.25,
    padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_googleRegisterButton(size), _registerButton(size)],
    ),
  );

  _loginButton(Size size) => ValueListenableBuilder<bool>(
    valueListenable: _isFormValid,
    builder: (context, isValid, _) => BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: size.width * 0.8,
          height: size.height * 0.05,
          child: ElevatedButton(
            onPressed: (isValid && !isLoading) ? _onSubmit : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              // textStyle: TextStyle()
              disabledForegroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            child: isLoading
                ? CircularProgressIndicator()
                : Text('Iniciar sesión'),
          ),
        );
      },
    ),
  );

  _registerButton(Size size) => SizedBox(
    width: size.width * 0.8,
    // color: Colors.lightBlueAccent,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿No tienes una cuenta?'),
        TextButton(
          onPressed: () {},
          child: Text(
            'Registrarme',
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ),
  );

  _googleRegisterButton(Size size) => SizedBox(
    height: 50,
    width: size.width * 0.8,
    child: SignInButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(24),
      ),
      Buttons.google, // logo + texto oficial
      text: "Continuar con Google",
      onPressed: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
    ),
  );

  _onSubmit() {
    if (!_isFormValid.value) return;

    context.read<AuthBloc>().add(
      SignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  InputBorder _inputBorder(Size size, Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(size.width * 0.02),
    borderSide: BorderSide(color: color, width: 1),
  );

  _clearTextField(TextEditingController controller) => IconButton(
    onPressed: () => setState(() {
      controller.clear();
    }),
    icon: Icon(Icons.close, color: Colors.grey, size: 20),
  );

  _obscureTextIconButton() => IconButton(
    onPressed: () => setState(() {
      _obscurePassword = !_obscurePassword;
    }),
    icon: Icon(
      _obscurePassword ? Icons.visibility : Icons.visibility_off,
      color: Colors.grey,
      size: 20,
    ),
  );
}
