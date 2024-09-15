part of 'user_list_bloc.dart';

abstract class UserListState {
  List<UserModel> users;

  UserListState({required this.users});
}

class UserListInitial extends UserListState {
  UserListInitial({required List<UserModel> users}) : super(users: users);
}

class UserListUpdate extends UserListState {
  UserListUpdate({required List<UserModel> users}) : super(users: users);
}
