import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:prestar_ropa_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Drawer(
      backgroundColor: Colors.white,
      width: size.width * 0.7,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(leading: Icon(Icons.person), title: _username()),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () => _logOut(context),
            ),
          ],
        ),
      ),
    );
  }

  _username() => BlocBuilder<UserBloc, UserState>(
    builder: (context, state) {
      if (state is UserLoaded) return Text('Hola ${state.user.username}!');
      return const Text('');
    },
  );

  _logOut(BuildContext context) {
    Navigator.pop(context);
    context.read<AuthBloc>().add(SignOutRequested());
  }
}
