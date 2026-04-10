import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/core/theme/app_styles.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/item/presentation/bloc/item_bloc.dart';
import '../../features/item/presentation/bloc/item_event.dart';
import '../../features/item/presentation/pages/home_page.dart';
import '../../features/shared/widgets/simple_widgets.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';
import '../../features/user/presentation/bloc/user_event.dart';
import '../../features/user/presentation/bloc/user_state.dart';
import '../../features/user/presentation/pages/complete_profile_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.read<UserBloc>().add(LoadCurrentUser(state.userId));
          context.read<ItemBloc>().add(LoadItems(state.userId));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) return _loader();

          if (authState is Authenticated) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                if (userState is UserLoading) {
                  return _loader();
                }
                if (userState is UserLoaded) {
                  if (userState.user.username.isEmpty) {
                    return const CompleteProfilePage();
                  } else {
                    return const HomePage();
                  }
                }
                if (userState is UserError) {
                  return _errorScreen('userState.message');
                }
                return _loader();
              },
            );
          }
          if (authState is Unauthenticated) {
            return const LoginPage();
          }
          return _loader();
        },
      ),
    );
  }

  _loader() => Scaffold(
    backgroundColor: AppStyles.secondaryColor,
    body: SimpleWidgets.loader(),
  );

  _errorScreen(String message) =>
      Scaffold(body: Center(child: Text('UserError, $message')));
}
