import 'package:azodhaassignment/widgets/gradient_bottom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:azodhaassignment/data/models/contact_model.dart';
import 'package:azodhaassignment/data/models/user_model.dart';

class ManageContactsScreen extends StatefulWidget {
  final UserModel user;

  const ManageContactsScreen({super.key, required this.user});

  @override
  State<ManageContactsScreen> createState() => _ManageContactsScreenState();
}

class _ManageContactsScreenState extends State<ManageContactsScreen> {
  late List<ContactModel> contacts;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailEController = TextEditingController();
  final TextEditingController phoneNumberEController = TextEditingController();
  final TextEditingController addressEController = TextEditingController();

  @override
  void initState() {
    super.initState();
    contacts = widget.user.contactModel;
  }

  void _addContact() async {
    setState(() {
      //we are checking the if the user model has contact if yes them next contact detail will be added with different id
      contacts.add(ContactModel(
        id: contacts.length + 1,
        name: widget.user.name,
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        address: addressController.text,
      ));
      nameController.clear();
      emailController.clear();
      phoneNumberController.clear();
      addressController.clear();
    });

//then are are updating the contact based on id
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id.toString());
    await userDoc.update({
      'contacts': contacts.map((contact) => contact.toMap()).toList(),
    });
  }

  void _editContact(int index) {
    final contact = contacts[index];
    nameController.text = contact.name;
    emailEController.text = contact.email;
    phoneNumberEController.text = contact.phoneNumber;
    addressEController.text = contact.address;

    bool validateEmail = false;
    bool validatePhoneNumber = false;
    bool validateAddress = false;
    void validate() {
      setState(() {
        validateEmail = emailEController.text.isEmpty;
        validatePhoneNumber = phoneNumberEController.text.isEmpty;
        validateAddress = addressEController.text.isEmpty;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Contact',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => validate,
                controller: emailEController,
                decoration: InputDecoration(
                    hintText: 'Email',
                    errorText:
                        validateEmail ? "The Email Text Can't be empty" : null),
              ),
              TextField(
                keyboardType: TextInputType.phone,
                controller: phoneNumberEController,
                decoration: InputDecoration(
                    hintText: 'Phone Number',
                    errorText: validatePhoneNumber
                        ? "The Phone Number Can't be empty"
                        : null),
              ),
              TextField(
                keyboardType: TextInputType.streetAddress,
                controller: addressEController,
                decoration: InputDecoration(
                    hintText: 'Address',
                    errorText: validatePhoneNumber
                        ? "The Address field Can't be empty"
                        : null),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                validate();
                if (validatePhoneNumber || validateEmail || validateAddress) {
                  // Show an error if validation fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter all required fields.')),
                  );
                  return;
                }
                setState(() {
                  contacts[index] = ContactModel(
                    id: contact.id,
                    name: nameController.text,
                    email: emailEController.text,
                    phoneNumber: phoneNumberEController.text,
                    address: addressEController.text,
                  );
                });

                final userDoc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.id.toString());
                await userDoc.update({
                  'contacts':
                      contacts.map((contact) => contact.toMap()).toList(),
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 255, 153),
              Color.fromARGB(255, 53, 39, 249),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Manage Contacts for ${widget.user.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: contacts.isEmpty
                ? Center(
                    child: Text(
                        "${widget.user.name}'s Contact information is not available"),
                  )
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];

                      return Container(
                        padding: const EdgeInsets.only(bottom: 4),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 53, 39, 249),
                              Color.fromARGB(255, 0, 255, 153),
                            ], // Your gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white),
                          child: ListTile(
                            title: const Text("Contact Details"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(" Email Id: ${contact.email}"),
                                Text(" Mobile Number: ${contact.phoneNumber}"),
                                Text(" Address: ${contact.address}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    setState(() {
                                      //we are removing the contact from model first
                                      contacts.removeAt(index);
                                    });
                                    // then we are updating the user with new model
                                    final userDoc = FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.user.id.toString());

                                    // Update Firestore with the new list of contacts
                                    await userDoc.update({
                                      'contacts': contacts
                                          .map((contact) => contact.toMap())
                                          .toList(),
                                    });
                                  },
                                ),
                                IconButton(
                                    onPressed: () => _editContact(index),
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 30,
                                      color: Colors.green,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 53, 39, 249),
                        Color.fromARGB(255, 0, 255, 153),
                      ], // Your gradient colors
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: Image.asset(
                    "assets/icons/Azodha.ico",
                    width: 50,
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                TextField(
                  keyboardType: TextInputType.phone,
                  controller: phoneNumberController,
                  decoration: const InputDecoration(hintText: 'Phone Number'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(hintText: 'Address'),
                ),
                const SizedBox(height: 8.0),
                GradientBorderButton(
                  onPressed: _addContact,
                  text: 'Add New Contact',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
