import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Crear cuenta'),
          backgroundColor: Colors.white,
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is Unauthenticated) {
              Navigator.pop(context);
            }
          },

          child: _registerBody(context, size),
        ),
      ),
    );
  }

  Widget _registerBody(BuildContext context, Size size) => SizedBox(
    width: size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _logoArea(size),
        SizedBox(
          width: size.width * 0.8,
          height: size.height * 0.35,
          child: _registerForm(context),
        ),
        SizedBox(height: size.height * 0.025),
        _backToLogin(context, size),
      ],
    ),
  );

  _logoArea(Size size) => SizedBox(
    width: size.width,
    height: size.height * 0.3,
    child: Center(
      child: Icon(
        Icons.key_sharp,
        size: size.width * 0.2,
        color: Colors.grey.shade300,
      ),
    ),
  );

  _registerForm(BuildContext context) => AuthForm(
    buttonText: "Registrarme",
    showExtras: false,
    isRegister: true,
    onSubmit: (email, password) {
      context.read<AuthBloc>().add(
        SignUpRequested(email: email, password: password),
      );
    },
  );

  _backToLogin(BuildContext context, Size size) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blueAccent),
      borderRadius: BorderRadius.circular(size.width * 0.06),
    ),
    width: size.width * 0.8,
    height: size.height * 0.05,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Volver a Login', style: TextStyle(color: Colors.blueAccent)),
    ),
  );
}
