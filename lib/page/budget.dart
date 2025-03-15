import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../budget_page/budget_form.dart';

class BudgetPage extends StatefulWidget {
  final String? token;
  const BudgetPage({super.key, required this.token});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List bgdata = [];
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
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_budget.php";
    try {
      var response = await http.get(Uri.parse(uri));

      setState(() {
        bgdata = jsonDecode(response.body);
        bgdata.sort(
          (a, b) => int.parse(b['budget_year']) - int.parse(a['budget_year']),
        ); // Sort by year descending
      });
    } catch (e) {
      print(e);
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
          _fetchUserRole().then((_) {
            getrecord();
          });
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
          });
          _fetchUserRole().then((_) {
            getrecord();
          });
        });
  }

  void _showAddBudgetForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BudgetForm(
              onBudgetAdded: () {
                // This is the callback function!
                getrecord(); // Refresh the list
              },
            ),
      ),
    );
    if (result == true) {
      getrecord(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "งบประมาณ",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.mali().fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (userRole == 'Admin')
            IconButton(
              onPressed: () {
                _showAddBudgetForm(context); // Call _showAddBudgetForm
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: bgdata.length,
        itemBuilder: (context, index) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bgdata[index]["budget_type"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  bgdata[index]["budget_name"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "งบประมาณ: ${bgdata[index]["budget_amount"]} บาท",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: GoogleFonts.mali().fontFamily,
                              ),
                            ),
                            Text(
                              "ประจำปี: ${bgdata[index]["budget_year"]}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: GoogleFonts.mali().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
