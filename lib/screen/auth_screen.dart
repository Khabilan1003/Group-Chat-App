import 'dart:io';

import 'package:chat_app/widget/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebaseAuthInstance = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _emailAddress = "";
  String _password = "";
  String _username = "";
  File? _selectedImage;
  bool isLoginIn = true;
  bool isLoading = false;

  void setProfileImage(File? image) {
    _selectedImage = image;
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (!isLoginIn && _selectedImage == null) return;

      setState(() {
        isLoading = true;
      });

      try {
        if (isLoginIn) {
          await _firebaseAuthInstance.signInWithEmailAndPassword(
            email: _emailAddress,
            password: _password,
          );
        } else {
          final userCreds =
              await _firebaseAuthInstance.createUserWithEmailAndPassword(
            email: _emailAddress,
            password: _password,
          );
          final storageRef = FirebaseStorage.instance
              .ref()
              .child("user_profile_picture")
              .child('${userCreds.user!.uid}.jpg');
          await storageRef.putFile(_selectedImage!);
          final imageDownloadUrl = await storageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCreds.user!.uid)
              .set({
            'email': _emailAddress,
            'username': _username,
            'image': imageDownloadUrl,
          });
        }
      } on FirebaseAuthException catch (exception) {
        if (exception.code == 'email-already-in-use') {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email already created"),
            ),
          );
        } else if (exception.code == 'invalid-email') {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Email"),
            ),
          );
        } else if (exception.code == 'weak-password') {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password is not strong"),
            ),
          );
        } else if (exception.code == 'wrong-password') {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Wrong Password"),
            ),
          );
        } else if (exception.code == 'user-not-found') {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email Not Registered"),
            ),
          );
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Authentication Error"),
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/chat.png"),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!isLoginIn)
                            UserImagePicker(setProfileImage: setProfileImage),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              label: Text("Email"),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Enter valid email address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _emailAddress = value!;
                            },
                          ),
                          if (!isLoginIn)
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text(
                                "Username",
                              )),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 4) {
                                  return 'username should be greater than 3 characters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text("Password"),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password should have atleast 6 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                            onPressed: submitForm,
                            child: isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ))
                                : Text(
                                    isLoginIn ? 'Login' : 'Signup',
                                  ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      isLoginIn = !isLoginIn;
                                    });
                                  },
                            child: Text(
                              isLoginIn
                                  ? 'Create a new account'
                                  : 'Already have an account',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
