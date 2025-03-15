import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/mainten_page/admin_maintenance.dart';
import 'package:ems_condb/mainten_page/mainten_report.dart'; // Import MaintenanceReport
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MaintenancePage extends StatefulWidget {
  final String? token;
  const MaintenancePage({Key? key, required this.token}) : super(key: key);

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  bool _isLoading = true;
  String userName = '';
  String userRole = '';

  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(
      Uri.parse('https://api.rmutsv.ac.th/elogin/token/${widget.token}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception(
        'Failed to retrieve user data. Status code: ${response.statusCode}',
      );
    }
  }

  Future<void> _fetchUserRole() async {
    String uri = "${baseUrl}view_user.php";
    try {
      var response = await http.get(Uri.parse(uri));
      final List<dynamic> users = jsonDecode(response.body);

      final user = users.firstWhere(
        (user) => user['user_name'] == userName,
        orElse: () => null,
      );

      if (user != null) {
        setState(() {
          userRole = user['user_role'] ?? '';
          _isLoading = false; // Set loading to false
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        _isLoading = false; // Set loading to false on error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData()
        .then((userData) {
          setState(() {
            userName = userData['name'] ?? 'User';
          });
          _fetchUserRole(); // Just call it
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
            _isLoading = false; // Set loading to false on error
          });
          _fetchUserRole(); // Call it here too
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "แจ้งซ่อม",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.mali().fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SizedBox(
          width: 500, // Limit width, good practice
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                    // Use GridView.count for easier layout
                    crossAxisCount: 2, // Two columns
                    childAspectRatio: 0.75, // Square items
                    padding: const EdgeInsets.all(8.0), // Add some padding
                    mainAxisSpacing: 8.0, // Spacing between rows
                    crossAxisSpacing: 8.0, // Spacing between columns
                    children: <Widget>[
                      _buildCard("ติดตามการซ่อม", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    MaintenanceReport(token: widget.token),
                          ),
                        );
                      }),
                      if (userRole == 'Admin') // Conditionally show admin card
                        _buildCard("รายการงานซ่อม\n(ช่างซ่อม)", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AdminMaintenance(token: widget.token),
                            ),
                          );
                        }),
                    ],
                  ),
        ),
      ),
    );
  }

  // Helper function to build the cards
  Widget _buildCard(String title, VoidCallback onTap) {
    return Card(
      elevation: 4.0, // Add some shadow
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0), // More padding
          child: Center(
            // Center the text
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.mali().fontFamily,
              ),
              textAlign: TextAlign.center, // Center text horizontally
            ),
          ),
        ),
      ),
    );
  }
}
