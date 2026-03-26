import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentUser extends UserEvent {
  final String userId;

  const LoadCurrentUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUserById extends UserEvent {
  final String id;

  const LoadUserById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateUserEvent extends UserEvent {
  final User user;

  const CreateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUserEvent extends UserEvent {
  final User user;

  const UpdateUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}
