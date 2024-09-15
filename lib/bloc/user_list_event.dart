part of 'user_list_bloc.dart';

@immutable
abstract class UserListEvent {}

class AddUser extends UserListEvent {
  final UserModel user;

  AddUser({required this.user});
}

class DeleteUser extends UserListEvent {
  final UserModel user;

  DeleteUser({required this.user});
}

class UpdateUser extends UserListEvent {
  final UserModel user;

  UpdateUser({required this.user});
}

class UpdateUserList extends UserListEvent {
  final List<UserModel> users;

  UpdateUserList({required this.users});
}
