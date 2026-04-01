import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_form.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(children: [_logoArea(size), _formArea(context, size)]),
        ),
      ),
    );
  }

  Widget _logoArea(Size size) => Container(
    width: size.width,
    height: size.height * 0.4,
    color: Colors.white,
    child: Center(
      child: Container(
        width: size.width * 0.45,
        height: size.height * 0.08,
        color: Colors.white54,
        child: Center(
          child: Icon(
            Icons.logo_dev,
            size: size.width * 0.25,
            color: Colors.grey.shade300,
          ),
        ),
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

  Widget _formButtons(BuildContext context, Size size) => SizedBox(
    width: size.width,
    height: size.height * 0.2,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_googleButton(context, size), _registerButton(context, size)],
    ),
  );

  Widget _googleButton(BuildContext context, Size size) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(size.width * 0.07),
    ),
    height: 50,
    width: size.width * 0.8,
    child: SignInButton(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(size.width * 0.07),
      ),
      Buttons.google,
      text: "Continuar con Google",
      onPressed: () => googleSignIn(context),
    ),
  );

  Widget _registerButton(BuildContext context, Size size) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      const Text('¿No tienes una cuenta?'),
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
        },
        child: const Text('Registrarme'),
      ),
    ],
  );

  googleSignIn(BuildContext context) =>
      context.read<AuthBloc>().add(GoogleSignInRequested());
}
