import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../config/config.dart';
import '../models/christian_modal.dart';
import '../models/victim_modal.dart';
import '../widgets/mobile.dart';
import 'edit_christian.dart';
import 'navBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _id;
  String? _jwtToken;
  String? _greeting = '';
  bool _isLoading = true;
  String _names = "";
  List<Victim> _allVictims = [];
  List<Christian> _allChristian = [];

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
        print("Christian Successful fetched");
        // Successful response, convert JSON to list of Victim objects
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Christian> christians = [];
        for (var json in jsonList) {
          christians.add(Christian.fromJson(json));
        }
        setState(() {
          _allChristian =
              christians; // Set the state variable with the list of victims
        });
      } else {
        // Handle error response
        if (kDebugMode) {
          print(
              "Failed to fetch christian. Status code: ${response.statusCode}");
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

  @override
  void initState() {
    super.initState();
    _checkUserInfo();
    _fetchAndPrintChristian();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(names: _names),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("All Christians"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: _allChristian.isEmpty
                ? [
                    const SizedBox(
                      height: 10,
                    ),
                    const Center(
                      child: Text(
                        'No christian yet registered',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ]
                : [
                    for (var christian in _allChristian)
                      ChristianCard(
                        christian: christian,
                      ),
                  ],
          ),
        ),
      ),
    );
  }
}

// Stateless widget for the Material UI card to display each victim
class VictimCard extends StatelessWidget {
  final Victim victim;

  const VictimCard({super.key, required this.victim});

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Victim Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("ID: ${victim.id}"),
              const Divider(),
              Text("Last Name: ${victim.lastName}"),
              const Divider(),
              Text("First Name: ${victim.firstName}"),
              const Divider(),
              Text("DOB: ${victim.dob}"),
              const Divider(),
              Text("Primary Phone: ${victim.primaryPhone}"),
              const Divider(),
              // ... Add other properties as needed ...
              Text("Category Name: ${victim.category.categoryName}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog when 'Close' is pressed
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("${victim.lastName} ${victim.firstName}"),
        subtitle: Text("DOB: ${victim.dob}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                _showDetailsDialog(
                    context); // Show the details dialog on button tap
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                int id = victim.id;
                String lastName = victim.lastName;
                String firstName = victim.firstName;
                DateTime dob = victim.dob;
                String primaryPhone = victim.primaryPhone;
                int categoryId = victim.category.id;
                String categoryName = victim.category.categoryName;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePage(
                          // id: id,
                          // lastName: lastName,
                          // firstName: firstName,
                          // dob: dob,
                          // primaryPhone: primaryPhone,
                          // categoryId: categoryId,
                          // categoryName: categoryName,
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChristianCard extends StatelessWidget {
  final Christian christian;

  const ChristianCard({super.key, required this.christian});

  Future<void> _createPDF() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    final font =
        PdfStandardFont(PdfFontFamily.helvetica, 35, style: PdfFontStyle.bold);

    const titleText = 'Baptism Certificate';
    String nameText = 'Names: ${christian.lastName} ${christian.firstName}';
    // String issuedByText = 'Issued by:';
    final currentDate = DateFormat('MM-dd-yyyy').format(DateTime.now());
    final dateText = 'Issued on: $currentDate';

    final pageSize = page.getClientSize();

    // Calculate the total height of all text lines
    final totalTextHeight = font.height * 4; // Four lines of text

    // Calculate the starting Y position for vertical centering
    final yPos = (pageSize.height - totalTextHeight) / 2;

    page.graphics.drawString(
      titleText,
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(
        45,
        yPos,
        pageSize.width,
        pageSize.height,
      ),
    );

    final nextYPos = yPos + font.height;

    page.graphics.drawString(
      nameText,
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(
        45,
        nextYPos,
        pageSize.width,
        pageSize.height,
      ),
    );

    final issuedByYPos = nextYPos + font.height;

    // page.graphics.drawString(
    //   issuedByText,
    //   font,
    //   brush: PdfSolidBrush(PdfColor(0, 0, 0)),
    //   bounds: Rect.fromLTWH(
    //     0,
    //     issuedByYPos,
    //     pageSize.width,
    //     pageSize.height,
    //   ),
    // );

    final dateYPos = issuedByYPos + font.height;

    page.graphics.drawString(
      dateText,
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(
        40,
        dateYPos,
        pageSize.width,
        pageSize.height,
      ),
    );

    List<int> bytes = await document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Output.pdf');
  }

  void _showDetailsDialog(BuildContext context) {
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
              Text("Primary Phone: ${christian.primaryPhone}"),
              const Divider(),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: _createPDF,
              child: const Text('Print Certificate '),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog when 'Close' is pressed
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDOB = DateFormat('dd MMMM yyyy').format(christian.dob);

    return Card(
      child: ListTile(
        title: Text("Names: ${christian.lastName} ${christian.firstName}"),
        subtitle: Text("DOB: ${formattedDOB}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                _showDetailsDialog(
                    context); // Show the details dialog on button tap
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                int id = christian.id;
                String lastName = christian.lastName;
                String firstName = christian.firstName;
                DateTime dob = christian.dob;
                String primaryPhone = christian.primaryPhone;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditChristianPage(
                            id: id,
                            lastName: lastName,
                            firstName: firstName,
                            dob: dob,
                            primaryPhone: primaryPhone,
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
