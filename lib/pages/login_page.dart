import 'dart:convert';

import 'package:amavunapp/pages/registration_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Animation/FadeAnimation.dart';
import '../common/theme_helper.dart';
import '../config/config.dart';
import '../models/login_response.dart';
import '../widgets/header_widget.dart';
import 'forget_password.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final double _headerHeight = 250;
  // final Key _formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  String loginApi = Config.loginApiUser;

  bool _isLoading = false;

  bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return false; // phone number is not provided
    }
    if (phoneNumber.length != 10) {
      return false; // phone number length is not 10
    }
    if (phoneNumber.substring(0, 3) != "078" &&
        phoneNumber.substring(0, 3) != "073" &&
        phoneNumber.substring(0, 3) != "079" &&
        phoneNumber.substring(0, 3) != "072") {
      return false; // phone number does not start with "078" or "073"
    }
    return true; // phone number is valid
  }

  bool isValidPassword(String phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return false; // phone number is not provided
    }
    return true; // phone number is valid
  }

  @override
  void dispose() {
    //clean up
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // Reset error messages
    setState(() {
      _isLoading = true;
    });
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // Prepare the body for the API call
    Map<String, dynamic> requestBody = {
      "phone": _phoneController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    // Perform the API call to sign-in
    final response = await http.post(
      Uri.parse(Config.loginApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );
    setState(() {
      _isLoading = false;
    });

    // Check the API response
    if (response.statusCode == 201) {
      // Successful login, handle the response
      LoginResponseModel loginResponse = loginResponseModel(response.body);

      if (loginResponse.status == 2) {
        setState(() {
          _errorMessage = "account not activated, contact admin..";
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _errorMessage = '';
          });
        });
        return;
      }
      if (loginResponse.text == "admin") {
        setState(() {
          _errorMessage = "only church elder allowed to login..";
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _errorMessage = '';
          });
        });
        return;
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        await prefs.setString('token', loginResponse.jwtToken);
        await prefs.setInt('id', loginResponse.id);
        await prefs.setString('names', loginResponse.names);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
      }
      // Debug print the response
      if (kDebugMode) {
        print(loginResponse.toJson());
      }
    } else {
      final errorData = jsonDecode(response.body);
      setState(() {
        _errorMessage = errorData['message'];
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true,
                  Icons.login_rounded), //let's create a common header widget
            ),
            SafeArea(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: const EdgeInsets.fromLTRB(
                      20, 10, 20, 10), // This will be the login form
                  child: Column(
                    children: [
                      const Text(
                        'Hello',
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Sign into your account',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _phoneController,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'number : 078../073..079',
                                      // 'Enter your phone number'),
                                      'enter your mobile number'),
                                  validator: (value) {
                                    if (!isValidPhoneNumber(value!)) {
                                      // return "Please enter a valid phone number";
                                      return "enter a valid number";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              Container(
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: ThemeHelper().textInputDecoration(
                                      // 'Password', 'Enter your password'),
                                      'Password',
                                      'Enter password'),
                                  validator: (value) {
                                    if (!isValidPassword(value!)) {
                                      return "Please provide a password";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 20),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgetPasswordPage()),
                                    );
                                  },
                                  child: const Text(
                                    // "Forgot your password?",
                                    "forget password",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration:
                                    ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 10, 40, 10),
                                    child: _isLoading
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    16, 0, 0, 0),
                                                child: Text(
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    "please wait..."),
                                                // "please wait..."),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            // 'Sign In'.toUpperCase(),
                                            'Log in'.toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (!_isLoading) {
                                        setState(() => _isLoading = true);
                                        _login();
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                //child: Text('Don\'t have an account? Create'),
                                child: Text.rich(TextSpan(children: [
                                  const TextSpan(
                                      // text: "Don\'t have an account? "),
                                      text: "not have account? "),
                                  TextSpan(
                                    text: ' Create',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RegistrationForm()));
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ])),
                              ),
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
