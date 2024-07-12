import 'dart:convert';

import 'package:amavunapp/common/theme_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'home_page.dart';
import 'navBar.dart';

class ChristianPage extends StatefulWidget {
  const ChristianPage({Key? key}) : super(key: key);

  @override
  State<ChristianPage> createState() => _ChristianPageState();
}

class _ChristianPageState extends State<ChristianPage> {
  String _names = "";
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime? _selectedDate;
  int? _selectedChurchId;

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _checkUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _names = prefs.getString('names')!;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = picked.toString();
      });
    }
  }

  Future<void> _submitForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Form validation passed, submit data
      final response = await http.post(
        Uri.parse(Config.registerChristianApi),
        body: {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'dob': _dobController.text,
          'email': _emailController.text,
          'user': prefs.getInt('id').toString(),
          'phoneNumber': _phoneController.text
        },
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      setState(() {
        _isLoading = false;
      });

      // Handle response as needed
      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Registration Successfully Done"),
              content:
                  const Text("You have registered new christian successfull "),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
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
        // Registration failed
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['message'];
        });
        print('Registration failed:  $_errorMessage');
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _errorMessage = '';
          });
        });
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(names: _names),
      appBar: AppBar(
        title: const Text("Register new member"),
        backgroundColor: ThemeHelper.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your date of birth';
                        }

                        DateTime selectedDate = DateTime.parse(value);
                        DateTime currentDate = DateTime.now();

                        // Calculate age based on the selected date of birth
                        int age = currentDate.year - selectedDate.year;
                        if (currentDate.month < selectedDate.month ||
                            (currentDate.month == selectedDate.month &&
                                currentDate.day < selectedDate.day)) {
                          age--;

                          if (kDebugMode) {
                            print("age : $age");
                          }

                          // Check if age is 12 or younger
                          if (age <= 11) {
                            return 'Christian must be at least 12 years old';
                          }

                          return null;
                        }
                      }),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Enter Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final pattern =
                      RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  } else if (!pattern.hasMatch(value)) {
                    return 'Invalid email address format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Enter Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final pattern = RegExp(r'^(07[8239])[0-9]{7}$');
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!pattern.hasMatch(value)) {
                    return 'Invalid phone number format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(primary: ThemeHelper.primaryColor),
                onPressed: _submitForm,
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                "Please wait..."),
                          ),
                        ],
                      )
                    : const Text('Register'),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "$_errorMessage",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }
}
