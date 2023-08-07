import 'dart:convert';

import 'package:amavunapp/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/church.dart';
import 'login_page.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DateTime? _selectedDate;
  List<Church> _churches = [];
  int? _selectedChurchId;

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _fetchChurches() async {
    final response = await http.get(Uri.parse(Config.getChurches));
    if (response.statusCode == 200) {
      final List<dynamic> churchList = jsonDecode(response.body);
      setState(() {
        _churches = churchList
            .map((churchJson) => Church.fromJson(churchJson))
            .toList();
      });
    } else {
      // Handle error fetching churches
      print('Error fetching churches: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchChurches();
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Form validation passed, submit data
      final response = await http.post(
        Uri.parse(Config.registerApiUser),
        body: {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'dob': _dobController.text,
          'phoneNumber': _phoneNumberController.text,
          "access_level": "string",
          'password': _passwordController.text,
          "profilePicture": "string",
          'church': _selectedChurchId.toString(),
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
              content: const Text("You have registered successfull "),
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
                    backgroundColor:
                        Colors.blue, // Set the background color to blue
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Form')),
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
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  final pattern = RegExp(r'(07[8,2,3,9])[0-9]{7}');
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!pattern.hasMatch(value)) {
                    return 'Invalid phone number format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                value: _selectedChurchId,
                items: _churches.map((church) {
                  return DropdownMenuItem<int>(
                    value: church.id,
                    child: Text(church.churchName),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedChurchId = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Church',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a church';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }
}
