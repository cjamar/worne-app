import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app/auth_gate.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user_id.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/user/data/datasources/user_remote_datasource_impl.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/usecases/create_user.dart';
import 'features/user/domain/usecases/get_current_user.dart';
import 'features/user/domain/usecases/get_user.dart';
import 'features/user/domain/usecases/update_user.dart';
import 'features/user/presentation/bloc/user_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hppldmbiocpnvkpguwbz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwcGxkbWJpb2NwbnZrcGd1d2J6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzMzI0NTgsImV4cCI6MjA4ODkwODQ1OH0.RUuO-UT17E_VPinqUJ5Z8goedwgTsmILcorFYzKUo8E',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  late final supabase = Supabase.instance.client;

  // User
  late final userRemoteDatasource = UserRemoteDataSourceImpl(supabase);
  late final userRepository = UserRepositoryImpl(userRemoteDatasource);

  late final getCurrentUser = GetCurrentUser(userRepository);
  late final getUser = GetUser(userRepository);
  late final createUser = CreateUser(userRepository);
  late final updateUser = UpdateUser(userRepository);

  // Auth
  late final authRemoteDatasource = AuthRemoteDatasourceImpl(supabase);
  late final authRepository = AuthRepositoryImpl(authRemoteDatasource);

  late final signIn = SignIn(authRepository);
  late final signUp = SignUp(authRepository);
  late final signInWithGoogle = SignInWithGoogle(authRepository);
  late final signOut = SignOut(authRepository);
  late final getCurrentUserId = GetCurrentUserId(authRepository);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signIn: signIn,
            signUp: signUp,
            signInWithGoogle: signInWithGoogle,
            signOut: signOut,
            getCurrentUserId: getCurrentUserId,
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<UserBloc>(
          create: (_) => UserBloc(
            getCurrentUser: getCurrentUser,
            getUser: getUser,
            createUser: createUser,
            updateUser: updateUser,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}
