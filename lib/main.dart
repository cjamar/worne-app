import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'features/item/data/datasources/item_remote_datasource_impl.dart';
import 'features/item/data/repositories/item_repository_impl.dart';
import 'features/item/domain/usecases/create_item.dart';
import 'features/item/domain/usecases/delete_item.dart';
import 'features/item/domain/usecases/get_items.dart';
import 'features/item/domain/usecases/group_shared_items_by_user.dart';
import 'features/item/domain/usecases/remove_item_from_shared.dart';
import 'features/item/domain/usecases/share_item.dart';
import 'features/item/domain/usecases/share_item_by_email.dart';
import 'features/item/domain/usecases/update_item.dart';
import 'features/item/domain/usecases/upload_item_image.dart';
import 'features/item/presentation/bloc/item_bloc.dart';
import 'features/user/data/datasources/user_remote_datasource_impl.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/usecases/create_user.dart';
import 'features/user/domain/usecases/ensure_user_exists.dart';
import 'features/user/domain/usecases/get_current_user.dart';
import 'features/user/domain/usecases/get_user.dart';
import 'features/user/domain/usecases/update_user.dart';
import 'features/user/domain/usecases/upload_user_avatar.dart';
import 'features/user/presentation/bloc/user_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
  late final ensureUserExists = EnsureUserExists(userRepository);
  late final uploadUserAvatar = UploadUserAvatar(userRepository);

  // Auth
  late final authRemoteDatasource = AuthRemoteDatasourceImpl(supabase);
  late final authRepository = AuthRepositoryImpl(authRemoteDatasource);

  late final signIn = SignIn(authRepository);
  late final signUp = SignUp(authRepository);
  late final signInWithGoogle = SignInWithGoogle(authRepository);
  late final signOut = SignOut(authRepository);
  late final getCurrentUserId = GetCurrentUserId(authRepository);

  // Item
  late final itemRemoteDatasource = ItemRemoteDatasourceImpl(supabase);
  late final itemRepository = ItemRepositoryImpl(itemRemoteDatasource);

  late final getItems = GetItems(itemRepository);
  late final createItem = CreateItem(itemRepository);
  late final updateItem = UpdateItem(itemRepository);
  late final deleteItem = DeleteItem(itemRepository);
  late final uploadItemImage = UploadItemImage(itemRepository);
  late final shareItem = ShareItem(itemRepository);
  late final shareItemByEmail = ShareItemByEmail(itemRepository);
  late final groupSharedItemsByUser = GroupSharedItemsByUser(itemRepository);
  late final removeItemFromShared = RemoveItemFromShared(itemRepository);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ItemBloc>(
          create: (_) => ItemBloc(
            getItems: getItems,
            groupSharedItemsByUser: groupSharedItemsByUser,
            createItem: createItem,
            updateItem: updateItem,
            deleteItem: deleteItem,
            uploadItemImage: uploadItemImage,
            shareItem: shareItem,
            shareItemByEmail: shareItemByEmail,
            removeItemFromShared: removeItemFromShared,
          ),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signIn: signIn,
            signUp: signUp,
            signInWithGoogle: signInWithGoogle,
            signOut: signOut,
            getCurrentUserId: getCurrentUserId,
            ensureUserExists: ensureUserExists,
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<UserBloc>(
          create: (_) => UserBloc(
            getCurrentUser: getCurrentUser,
            getUser: getUser,
            createUser: createUser,
            updateUser: updateUser,
            uploadUserAvatar: uploadUserAvatar,
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
