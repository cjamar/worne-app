import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 50,
          width: 250,
          child: SignInButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(24),
            ),
            Buttons.google, // logo + texto oficial
            text: "Continuar con Google",
            onPressed: () =>
                context.read<AuthBloc>().add(GoogleSignInRequested()),
          ),
        ),
        // child: ElevatedButton.icon(
        //   onPressed: () =>
        //       context.read<AuthBloc>().add(GoogleSignInRequested()),
        //   icon: FaIcon(FontAwesomeIcons.google, color: Color(0xFFEA4335)),
        //   label: const Text(
        //     'Autenticación con Google',
        //     style: TextStyle(color: Colors.black54),
        //   ),
        // ),
      ),
    );
  }

  // _loginWithGoogle(BuildContext context) async {
  //   // 1️⃣ Login con AuthRepository (aún por implementar)
  //   // Simulamos que obtenemos el userId y email de Supabase Auth
  //   final userId = '123'; // ejemplo
  //   // final email = De momento no la usamos
  //   // final username = De momento no la usamos

  //   // 3️⃣ Cargamos el usuario actual
  //   context.read<UserBloc>().add(LoadCurrentUser(userId));

  //   // 4️⃣ Navegamos a profile page
  //   Navigator.of(
  //     context,
  //   ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
  // }
}
