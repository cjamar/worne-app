import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:prestar_ropa_app/features/auth/presentation/bloc/auth_event.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Drawer(
      backgroundColor: Colors.white,
      width: size.width * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.05,
            ),
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () => _logOut(context),
            ),
          ),
        ],
      ),
    );
  }

  _logOut(BuildContext context) {
    Navigator.pop(context);
    context.read<AuthBloc>().add(SignOutRequested());
  }
}
