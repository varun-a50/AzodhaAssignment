// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:azodhaassignment/data/models/contact_model.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final List<ContactModel> contactModel;
  const UserModel({
    required this.id,
    required this.name,
    required this.contactModel,
  });

  // Convert a UserModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contacts': contactModel.map((contact) => contact.toMap()).toList(),
    };
  }

  // Create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      contactModel: List<ContactModel>.from(
        (map['contacts'] as List)
            .map((contact) => ContactModel.fromMap(contact)),
      ),
    );
  }

  @override
  List<Object> get props => [id, name, contactModel];
}
