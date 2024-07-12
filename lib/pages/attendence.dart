import 'dart:convert';

import 'package:amavunapp/common/theme_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/christian_modal.dart';
import '../models/victim_modal.dart';
import '../widgets/mobile.dart';
import 'edit_christian.dart';
import 'home_page.dart';
import 'navBar.dart';

class AttendencePage extends StatefulWidget {
  const AttendencePage({Key? key}) : super(key: key);

  @override
  State<AttendencePage> createState() => _AttendencePageState();
}

class _AttendencePageState extends State<AttendencePage> {
  int? _id;
  String? _jwtToken;
  String? _greeting = '';
  bool _isLoading = true;
  String _names = "";
  List<Victim> _allVictims = [];
  List<Christian> _allChristian = [];
  TextEditingController _searchController = TextEditingController();
  List<Christian> _filteredChristian = [];

  Future<void> _checkUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _jwtToken = prefs.getString('token');
      _id = prefs.getInt('id');
      _names = prefs.getString('names')!;
    });
  }

  Future<void> _fetchAndPrintChristian() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Fetch data from the API
      final response = await http.get(
        Uri.parse(Config.fetchChristianApi),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );
      if (response.statusCode == 200) {
        print("Christian Successfully fetched");
        // Successful response, convert JSON to a list of Christian objects
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Christian> christians = [];
        for (var json in jsonList) {
          christians.add(Christian.fromJson(json));
          print(Christian.fromJson(json).lastName);
        }
        setState(() {
          _allChristian =
              christians; // Set the state variable with the list of Christians
          _filteredChristian =
              _allChristian; // Initialize the filtered list with all Christians.
        });
      } else {
        // Handle error response
        if (kDebugMode) {
          print(
              "Failed to fetch Christian. Status code: ${response.statusCode}");
        }
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      // Handle any exceptions that may occur during the API call
      print("Error occurred: $e");
    }
  }

  void _filterChristian(String searchQuery) {
    setState(() {
      _filteredChristian = _allChristian
          .where((christian) =>
              christian.firstName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              christian.lastName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _checkUserInfo();
    _fetchAndPrintChristian();
  }

  void _showDetailsDialog(BuildContext context, Christian christian) {
    showDialog(
      context: context,
      builder: (context) {
        // Format the DOB into "dd MMMM yyyy" format
        String formattedDOB = DateFormat('dd MMMM yyyy').format(christian.dob);

        return AlertDialog(
          title: const Text("Christian Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("ID: ${christian.id}"),
              const Divider(),
              Text("Last Name: ${christian.lastName}"),
              const Divider(),
              Text("First Name: ${christian.firstName}"),
              const Divider(),
              Text("DOB: $formattedDOB"), // Display the formatted DOB
              const Divider(),
              Text("Primary Phone: ${christian.email}"),
              const Divider(),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _submitAttendance(context, christian.id, "present");
                  },
                  style: ElevatedButton.styleFrom(
                      primary: ThemeHelper.primaryColor),
                  child: const Text("Present"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _submitAttendance(context, christian.id, "absent");
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text("Absent"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _submitAttendance(
      BuildContext context, int christianId, String status) async {
    final currentDate = DateTime.now().toUtc().toIso8601String();
    final url = status == "present"
        ? Config.createPresenceAttendence
        : Config.createAbsenceAttendence;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = {
      "date": currentDate,
      "status": status,
      "christian": christianId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token')}',
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Attendance submitted as $status"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to submit attendance"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error occurred while submitting attendance"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(names: _names),
      appBar: AppBar(
        backgroundColor: ThemeHelper.primaryColor,
        title: const Text("Attendance Page"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filterChristian(value);
              },
              decoration: InputDecoration(
                labelText: 'Search by First Name or Last Name',
                labelStyle: TextStyle(
                    color:
                        ThemeHelper.primaryColor), // Set the label text color
                prefixIcon: Icon(Icons.search,
                    color: ThemeHelper.primaryColor), // Set the icon color
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: ThemeHelper
                          .primaryColor), // Set the bottom border color
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: ThemeHelper
                          .primaryColor), // Set the bottom border color
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChristian.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      "Names: ${_filteredChristian[index].lastName} ${_filteredChristian[index].firstName}",
                    ),
                    subtitle: Text(
                      "DOB: ${DateFormat('dd MMMM yyyy').format(_filteredChristian[index].dob)}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () {
                            _showDetailsDialog(
                                context, _filteredChristian[index]);
                          },
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.edit),
                        //   onPressed: () {
                        //     int id = _filteredChristian[index].id;
                        //     String lastName =
                        //         _filteredChristian[index].lastName;
                        //     String firstName =
                        //         _filteredChristian[index].firstName;
                        //     DateTime dob = _filteredChristian[index].dob;
                        //     String email = _filteredChristian[index].email;
                        //
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => EditChristianPage(
                        //           id: id,
                        //           lastName: lastName,
                        //           firstName: firstName,
                        //           dob: dob,
                        //           email: email,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
