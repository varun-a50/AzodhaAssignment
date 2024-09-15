// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  const ContactModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });

  // Convert a ContactModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  // Create a ContactModel from a Map
  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
    );
  }

  @override
  List<Object> get props {
    return [
      id,
      name,
      email,
      phoneNumber,
      address,
    ];
  }
}
