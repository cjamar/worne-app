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

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),

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
    );
  }

  Widget _registerBody(BuildContext context, Size size) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _logoArea(size),
      SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.35,
        child: _registerForm(context),
      ),
      _backToLogin(context, size),
    ],
  );

  _logoArea(Size size) => Container(
    width: size.width,
    height: size.height * 0.3,
    color: Colors.black12,
    child: Center(child: Text('Image')),
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

  _backToLogin(BuildContext context, Size size) => Padding(
    padding: EdgeInsets.only(top: size.height * 0.03),
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Volver a Login'),
    ),
  );
}
