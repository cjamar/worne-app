import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/item/presentation/pages/home_page.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_event.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_state.dart';
import 'package:prestar_ropa_app/features/user/presentation/pages/complete_profile_page.dart';
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
            return _loader();
          }
          if (state is Authenticated) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return _loader();
                }
                if (state is UserLoaded) {
                  if (state.user.username.isEmpty) {
                    return const CompleteProfilePage();
                  }
                }
                return const HomePage();
              },
            );
          }
          if (state is Unauthenticated) {
            return const LoginPage();
          }
          return _loader(); // habrá que cambiarlo por un container error
        },
      ),
    );
  }

  _loader() => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
