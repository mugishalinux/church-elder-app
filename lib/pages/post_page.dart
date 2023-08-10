import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'home_page.dart';
import 'navBar.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String _names = "";
  bool _isLoading = false;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postContentController = TextEditingController();

  Future<void> _checkUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _names = prefs.getString('names')!;
    });
  }

  Future<void> _submitForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Form validation passed, submit data
      final response = await http.post(
        Uri.parse(Config.postApi),
        body: {
          'postTitle': _postTitleController.text,
          'postContent': _postContentController.text,
          'user': prefs.getInt('id').toString(),
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
              title: const Text("Post Successfully Sent"),
              content: const Text(
                  "You have successfull sent post to all your christians "),
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
  void initState() {
    super.initState();
    _checkUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(names: _names),
      appBar: AppBar(
        title: const Text("Post"),
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
                controller: _postTitleController,
                decoration: const InputDecoration(
                  labelText: 'Post Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter post title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _postContentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Post Content',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter post content';
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
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                "Please wait..."),
                          ),
                        ],
                      )
                    : const Text('Send Post'),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                _errorMessage,
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
