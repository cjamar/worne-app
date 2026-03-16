import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prestar_ropa_app/features/user/presentation/bloc/user_bloc.dart';

import '../bloc/user_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Username: ${state.user.username}'),
                  Text('Email: ${state.user.email}'),
                ],
              ),
            );
          } else if (state is UserError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No se ha cargado el usuario'));
        },
      ),
    );
  }
}
