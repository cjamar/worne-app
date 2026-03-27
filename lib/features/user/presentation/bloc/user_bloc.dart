import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/get_user.dart';
import '../../domain/usecases/update_user.dart';
import '../../domain/usecases/upload_user_avatar.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetCurrentUser getCurrentUser;
  final GetUser getUser;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final UploadUserAvatar uploadUserAvatar;

  UserBloc({
    required this.getCurrentUser,
    required this.getUser,
    required this.createUser,
    required this.updateUser,
    required this.uploadUserAvatar,
  }) : super(UserInitial()) {
    on<LoadCurrentUser>((event, emit) async {
      emit(UserLoading());

      try {
        User? user = await getUser(event.userId);

        if (user == null) {
          // se crea el perfil si no existe
          final newUser = User(
            id: event.userId,
            email: '',
            username: '',
            avatarUrl: '',
          );
          await createUser(newUser);
          user = await getUser(event.userId);
        }
        emit(UserLoaded(user!));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<LoadUserById>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await getUser(event.id);
        if (user != null) {
          emit(UserLoaded(user));
        } else {
          emit(const UserError('Usuario no encontrado'));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<CreateUserEvent>((event, emit) async {
      emit(UserLoading());

      try {
        final user = await createUser(event.user);
        emit(UserLoaded(user));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUserEvent>((event, emit) async {
      emit(UserLoading());

      try {
        final updatedUser = await updateUser(event.user);
        emit(UserLoaded(updatedUser));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<UploadUserAvatarEvent>((event, emit) async {
      try {
        final currentState = state;

        final url = await uploadUserAvatar(event.file);

        if (currentState is UserLoaded) {
          final updatedUser = currentState.user.copyWith(avatarUrl: url);

          emit(UserLoaded(updatedUser)); // 🔥 CLAVE
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
