import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/config.dart';
import '../models/christian_modal.dart';
import 'home_page.dart';
import 'navBar.dart';

class EditChristianPage extends StatefulWidget {
  final int id;
  final String lastName;
  final String firstName;
  final DateTime dob;
  final String primaryPhone;

  const EditChristianPage({
    Key? key,
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.dob,
    required this.primaryPhone,
  }) : super(key: key);

  @override
  State<EditChristianPage> createState() => _EditChristianPageState();
}

class _EditChristianPageState extends State<EditChristianPage> {
  int? _id;
  String? _jwtToken;
  String? _greeting = '';
  bool _isLoading = false;
  String _names = '';
  String _editedFirstName = '';
  String _editedLastName = '';
  String _editedPhoneNumber = '';
  DateTime? _editedDOB;
  final TextEditingController _dobController = TextEditingController();
  final FocusNode _dobFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  List<Christian> _allChristian = [];

  DateTime? _selectedDate;

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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchAndPrintChristian() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse(Config.fetchChristianApi),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Christian> christians = [];
        for (var json in jsonList) {
          christians.add(Christian.fromJson(json));
        }
        setState(() {
          _allChristian = christians;
        });
      } else {
        if (kDebugMode) {
          print(
              "Failed to fetch christian. Status code: ${response.statusCode}");
        }
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> _submitForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });

    final response = await http.put(
      Uri.parse('${Config.updateChristianApi}/${widget.id}'),
      body: {
        'firstName': _editedFirstName,
        'lastName': _editedLastName,
        // 'dob': _editedDOB?.toString() ?? '',
        'dob': _dobController.text,
        'phoneNumber': _editedPhoneNumber,
        'user': prefs.getInt('id').toString(),
      },
      headers: {
        'Authorization': 'Bearer ${prefs.getString('token')}',
      },
    );
    setState(() {
      _isLoading = false;
    });
    print("status : ${response.statusCode}");
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Successfully Done"),
            content: const Text("You have successfully updated info "),
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
                  backgroundColor: Colors.blue,
                ),
                child:
                    const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } else {
      final errorData = jsonDecode(response.body);
      setState(() {
        _errorMessage = errorData['message'];
      });
      print('Registration failed: $_errorMessage');
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

  @override
  void initState() {
    super.initState();
    _checkUserInfo();
    _fetchAndPrintChristian();
    _editedFirstName = widget.firstName;
    _editedLastName = widget.lastName;
    _editedPhoneNumber = widget.primaryPhone;
    // Set initial value for the DOB field
    _dobController.text = DateFormat('dd MMMM yyyy').format(widget.dob);
  }

  @override
  void dispose() {
    _dobFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Update Christina Info"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                initialValue: _editedFirstName,
                onChanged: (value) {
                  setState(() {
                    _editedFirstName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                initialValue: _editedLastName,
                onChanged: (value) {
                  setState(() {
                    _editedLastName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dobController,
                focusNode: _dobFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // Prevent manual input
                onTap: () async {
                  _dobFocusNode.unfocus(); // Hide keyboard if open
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? widget.dob,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                      _dobController.text = DateFormat('yyyy-MM-dd')
                          .format(picked); // Always use 'yyyy-MM-dd' format
                    });
                  } else {
                    _dobController.text = DateFormat('yyyy-MM-dd')
                        .format(widget.dob); // Always use 'yy
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }

                  // ... Existing validation logic ...
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                initialValue: _editedPhoneNumber,
                onChanged: (value) {
                  setState(() {
                    _editedPhoneNumber = value;
                  });
                },
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
                              "Please wait...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
