import 'package:azodhaassignment/bloc/user_list_bloc.dart';
import 'package:azodhaassignment/data/models/contact_model.dart';
import 'package:azodhaassignment/data/models/user_model.dart';
import 'package:azodhaassignment/screens/manage_contact_screen.dart';
import 'package:azodhaassignment/widgets/gradient_bottom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

//we are using this function to fetch data from user collection
  void _fetchUsers() async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final snapshot = await userCollection.get();
    final users = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    context.read<UserListBloc>().add(UpdateUserList(users: users));
  }

  bool _isVisible = false;
  //this function runs when every time the screen is visible to user
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Check if the screen is currently visible to the user
    if (ModalRoute.of(context)?.isCurrent == true && !_isVisible) {
      _isVisible = true;
      setState(() {
        _fetchUsers();
      });
    } else if (ModalRoute.of(context)?.isCurrent == false) {
      _isVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Adjust height if needed

        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 255, 153),
              Color.fromARGB(255, 53, 39, 249),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "AZODHA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      //we have some errors in BLOC state management so we are using StreamBuilder to listen to live update from the firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs
                  .map((doc) =>
                      UserModel.fromMap(doc.data() as Map<String, dynamic>))
                  .toList() ??
              [];

          if (users.isEmpty) {
            return const SizedBox(
              width: double.infinity,
              child: Center(
                child: Text("No Users found"),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ManageContactsScreen(user: user),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 53, 39, 249),
                            Color.fromARGB(255, 0, 255, 153),
                          ], // Your gradient colors
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: buildUserTile(context, user, index))),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 53, 39, 249),
              Color.fromARGB(255, 0, 255, 153),
            ], // Your gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            //we are clearing the textfields before adding new user
            nameController.text = "";
            emailController.text = "";
            mobileNumberController.text = "";
            addressController.text = "";
            final state = context.read<UserListBloc>().state;
            final id = state.users.length + 1;
            showBottomSheet(context: context, id: id);
          },
        ),
      ),
    );
  }

// this function builds each user tile
  Widget buildUserTile(BuildContext context, UserModel user, int index) {
    return ListTile(
      title: Text(
        user.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: user.contactModel.isNotEmpty
          ? Text(user.contactModel[0].email,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
          : const Text("No data available"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                context.read<UserListBloc>().add(DeleteUser(user: user));
              },
              icon: const Icon(
                Icons.delete,
                size: 30,
                color: Colors.red,
              )),
          IconButton(
              onPressed: () {
                nameController.text = user.name;
                emailController.text = user.contactModel[0].email;
                mobileNumberController.text = user.contactModel[0].phoneNumber;
                addressController.text = user.contactModel[0].address;

                showBottomSheet(context: context, id: user.id, isEdit: true);
              },
              icon: const Icon(
                Icons.edit,
                size: 30,
                color: Colors.green,
              ))
        ],
      ),
    );
  }

//we are validating each field so the user wont be able to pass null value
  bool validateEmail = false;
  bool validatePhoneNumber = false;
  bool validateAddress = false;
  bool validateName = false;
  void validate() {
    setState(() {
      validateEmail = emailController.text.isEmpty;
      validatePhoneNumber = mobileNumberController.text.isEmpty;
      validateAddress = addressController.text.isEmpty;
      validateName = nameController.text.isEmpty;
    });
  }

//to edit and add new user we are using bottomSheet
  void showBottomSheet(
      {required BuildContext context, bool isEdit = false, required int id}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(4), // Thickness of the border
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [
                Color.fromARGB(255, 0, 255, 153),
                Color.fromARGB(255, 53, 39, 249)
              ])),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color of the content
              borderRadius:
                  BorderRadius.circular(12), // Match with outer border radius
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/icons/Azodha.ico",
                      width: 50,
                    ),
                  ),
                  buildTextField(
                      errorText:
                          validateName ? "The Name Text Can't be empty" : null,
                      controller: nameController,
                      hint: "Enter Name",
                      keyboardType: TextInputType.name),
                  buildTextField(
                      errorText:
                          validateEmail ? "The Email Can't be empty" : null,
                      controller: emailController,
                      hint: "Enter Email",
                      keyboardType: TextInputType.emailAddress),
                  buildTextField(
                      errorText: validatePhoneNumber
                          ? "The Mobile Number Can't be empty"
                          : null,
                      controller: mobileNumberController,
                      hint: "Enter Mobile Number",
                      keyboardType: TextInputType.phone),
                  buildTextField(
                      errorText: validateAddress
                          ? "The Address Text Can't be empty"
                          : null,
                      controller: addressController,
                      hint: "Enter Address",
                      keyboardType: TextInputType.streetAddress),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GradientBorderButton(
                      onPressed: () async {
                        validate();
                        if (validatePhoneNumber ||
                            validateEmail ||
                            validateAddress ||
                            validateName) {
                          // Show an error if validation fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter all required fields.')),
                          );
                          return;
                        }
                        final user = UserModel(
                            id: id,
                            name: nameController.text,
                            contactModel: [
                              ContactModel(
                                  id: id,
                                  name: nameController.text,
                                  email: emailController.text,
                                  phoneNumber: mobileNumberController.text,
                                  address: addressController.text)
                            ]);

                        final userCollection =
                            FirebaseFirestore.instance.collection('users');

                        if (isEdit) {
                          await userCollection
                              .doc(id.toString())
                              .update(user.toMap());
                        } else {
                          await userCollection
                              .doc(id.toString())
                              .set(user.toMap());
                        }

                        // Close the bottom sheet
                        Navigator.pop(context);

                        // Refresh the state
                        setState(() {
                          _fetchUsers(); // Fetch updated user data
                        });
                      },
                      text: isEdit ? "UPDATE" : "ADD",
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

//this function builds textField it is just a way we could have directly used the text field but this way we get simillar textfields
  static Widget buildTextField(
          {required TextEditingController controller,
          required String hint,
          required String? errorText,
          required TextInputType? keyboardType}) =>
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          keyboardType: keyboardType,
          controller: controller,
          decoration: InputDecoration(
              errorText: errorText,
              hintText: hint,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
      );
}
