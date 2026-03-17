import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user_id.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUserId getCurrentUserId;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUserId,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      final userId = getCurrentUserId();

      if (userId != null) {
        emit(Authenticated(userId));
      } else {
        emit(Unauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await signIn(email: event.email, password: event.password);

        final userId = getCurrentUserId();

        if (userId != null) {
          emit(Authenticated(userId));
        } else {
          emit(const AuthError('Error al hacer login'));
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await signUp(email: event.email, password: event.password);

        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      }
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await signInWithGoogle();

        add(AuthCheckRequested());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(Unauthenticated());
      }
    });

    on<SignOutRequested>((event, emit) async {
      await signOut();
      emit(Unauthenticated());
    });
  }
}
