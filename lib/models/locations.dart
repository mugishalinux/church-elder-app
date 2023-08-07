import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Location {
  final int id;
  final String locationName;
  final String locationImage;

  Location({
    required this.id,
    required this.locationName,
    required this.locationImage,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      locationName: json['locationName'],
      locationImage: json['locationImage'],
    );
  }
}
