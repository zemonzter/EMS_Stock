import 'dart:convert';
import 'dart:developer'; // Import for log()

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/budget_page/edit_budget.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package
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
      log('Error fetching user role: $e'); // Use log() for debugging
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
      log('getrecord() error: $e'); // Use log()
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
          log('Error fetching user data: $error'); // Use log()
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

  // Function to navigate to EditBudget page
  void _navigateToEditBudget(
    BuildContext context,
    Map<String, dynamic> budgetData,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBudget(budgetData: budgetData),
      ),
    );
    // Check if the EditBudget page sent back a signal to refresh
    if (result == true) {
      getrecord(); // Refresh the list
    }
  }

  // Helper function to format numbers with commas
  String formatNumber(dynamic number) {
    if (number == null) {
      return ''; // Or any default value
    }
    final formatter = NumberFormat("#,###");

    // Check if is already a String
    if (number is String) {
      // Try to convert the string.  If fail, just return the original string
      return int.tryParse(number) != null
          ? formatter.format(int.parse(number))
          : number;
    } else if (number is int) {
      return formatter.format(number);
    } else if (number is double) {
      return formatter.format(number);
    }
    return number.toString(); // Fallback for other types.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "งบประมาณ",
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
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
                  GestureDetector(
                    // Wrap with GestureDetector
                    onTap: () {
                      // Navigate to EditBudget when tapped
                      if (userRole == 'Admin') {
                        // Check for Admin role
                        _navigateToEditBudget(context, bgdata[index]);
                      }
                    },
                    child: Container(
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
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    bgdata[index]["budget_name"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: Fonts.Fontnormal.fontFamily,
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
                                "งบประมาณ: ${formatNumber(bgdata[index]["budget_amount"])} บาท", // Format the number here
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              Text(
                                "ประจำปี: ${bgdata[index]["budget_year"]}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
