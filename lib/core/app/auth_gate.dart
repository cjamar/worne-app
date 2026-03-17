import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_event.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.read<UserBloc>().add(LoadCurrentUser(state.userId));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is Authenticated) {
            // aqui irá la HomePage
            return const Scaffold(
              backgroundColor: Color.fromARGB(255, 167, 249, 181),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 80)),
                    SizedBox(height: 10),
                    Text('Usuario autenticado', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            );
          }
          if (state is Unauthenticated) {
            return const LoginPage();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
