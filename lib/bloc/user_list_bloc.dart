import 'package:azodhaassignment/data/models/user_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc() : super(UserListInitial(users: [])) {
    on<AddUser>(_addUser);
    on<DeleteUser>(_deleteUser);
    on<UpdateUser>(_updateUser);
    on<UpdateUserList>(_onUpdateUserList);
  }

  void _addUser(AddUser event, Emitter<UserListState> emit) {
    state.users.add(event.user);
    emit(UserListUpdate(users: state.users));
  }

  void _deleteUser(DeleteUser event, Emitter<UserListState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.user.id.toString())
          .delete();

      // Remove user from the state and update
      final updatedUsers = (state as UserListUpdate)
          .users
          .where((user) => user.id != event.user.id)
          .toList();

      emit(UserListUpdate(users: updatedUsers));
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  void _updateUser(UpdateUser event, Emitter<UserListState> emit) {
    for (int i = 0; i < state.users.length; i++) {
      if (event.user.id == state.users[i].id) {
        state.users[i] = event.user;
      }
    }
    emit(UserListUpdate(users: state.users));
  }

  void _onUpdateUserList(UpdateUserList event, Emitter<UserListState> emit) {
    emit(UserListUpdate(users: event.users));
  }
}
