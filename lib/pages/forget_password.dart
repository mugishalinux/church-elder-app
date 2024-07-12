import 'dart:convert';
import 'package:amavunapp/common/theme_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../config/config.dart';
import 'login_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? _responseMessage;
  String resetPasswordApi = Config.resetPasswordApi;

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> requestBody = {
        "phoneNumber": phoneNumberController.text,
        "dob": int.parse(dobController.text),
        "password": passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse(resetPasswordApi),
          body: jsonEncode(requestBody),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 201) {
          // Password reset successful, show success modal
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Password Successfully Updated"),
                content:
                    const Text("You have updated successfull your password "),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: ThemeHelper
                          .primaryColor, // Set the background color to blue
                    ),
                    child: const Text("Close",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        } else {
          final errorData = jsonDecode(response.body);
          setState(() {
            _responseMessage = errorData['message'] ?? 'Unknown error occurred';
          });
        }
      } catch (e) {
        setState(() {
          _responseMessage = 'An error occurred: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: ThemeHelper.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dobController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Year of Birth',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your year of birth';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  primary:
                      ThemeHelper.primaryColor, // Set the primary color here
                ),
                child: const Text('Reset Password'),
              ),
              if (_responseMessage != null)
                Center(
                  child: Text(
                    _responseMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
