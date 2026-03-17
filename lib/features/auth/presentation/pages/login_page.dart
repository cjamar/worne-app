import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/auth_form.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(children: [_logoArea(size), _formArea(context, size)]),
      ),
    );
  }

  Widget _logoArea(Size size) => Container(
    width: size.width,
    height: size.height * 0.4,
    color: Colors.black87,
    child: Center(
      child: Container(
        width: size.width * 0.45,
        height: size.height * 0.08,
        color: Colors.white54,
        child: const Center(child: Text('Logo')),
      ),
    ),
  );

  Widget _formArea(BuildContext context, Size size) => Container(
    width: size.width,
    height: size.height * 0.6,
    color: Colors.white,
    child: Column(
      children: [_formBody(context, size), _formButtons(context, size)],
    ),
  );

  Widget _formBody(BuildContext context, Size size) => Container(
    color: Colors.white24,
    width: size.width * 0.9,
    height: size.height * 0.35,
    child: AuthForm(
      buttonText: "Iniciar sesión",
      isRegister: false,
      onSubmit: (email, password) {
        context.read<AuthBloc>().add(
          SignInRequested(email: email, password: password),
        );
      },
    ),
  );

  Widget _formButtons(BuildContext context, Size size) => Container(
    color: Colors.black26,
    width: size.width,
    height: size.height * 0.25,
    padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [_googleButton(context, size), _registerButton(context, size)],
    ),
  );

  Widget _googleButton(BuildContext context, Size size) => SizedBox(
    height: 50,
    width: size.width * 0.8,
    child: SignInButton(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(size.width * 0.07),
      ),
      Buttons.google,
      text: "Continuar con Google",
      onPressed: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
    ),
  );

  Widget _registerButton(BuildContext context, Size size) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('¿No tienes una cuenta?'),
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
        },
        child: const Text(
          'Registrarme',
          style: TextStyle(fontSize: 12, decoration: TextDecoration.underline),
        ),
      ),
    ],
  );
}
