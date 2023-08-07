import 'dart:convert';

import 'package:flutter/cupertino.dart';

LoginResponseModel loginResponseModel(String str) =>
    LoginResponseModel.fromJson(jsonDecode(str));

class LoginResponseModel {
  int id;
  String names;
  int status;
  String text;
  String jwtToken;
  DateTime createdAt;

  LoginResponseModel({
    required this.id,
    required this.names,
    required this.status,
    required this.text,
    required this.jwtToken,
    DateTime? createdAt, // Updated property
  }) : createdAt = createdAt ??
            DateTime.now(); // Set default value to current datetime

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      id: json['id'],
      names: json['names'],
      status: json['status'],
      text: json['access_level'],
      jwtToken: json['jwtToken'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'text': text,
      'jwtToken': jwtToken,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
