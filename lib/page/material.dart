import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/mt_page/checkout/admin_ap.dart';
import 'package:ems_condb/mt_page/checkout/checkout_mt_report.dart';
import 'package:ems_condb/mt_page/checkout/checkout_report.dart';
import 'package:ems_condb/mt_page/material_consum.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../user_page/settings/setting_eq/inserteqt.dart';

class MaterialHome extends StatefulWidget {
  final String token;
  const MaterialHome({super.key, required this.token});

  @override
  State<MaterialHome> createState() => _MaterialHomeState();
}

class _MaterialHomeState extends State<MaterialHome> {
  List types = [];
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
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> getType() async {
    setState(() {
      _isLoading = true;
    });
    String uri = "${baseUrl}view_mttype.php";
    try {
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          setState(() {
            types = List<Map<String, dynamic>>.from(decodedResponse);
            _isLoading = false;
          });
        } else if (decodedResponse is Map &&
            decodedResponse['success'] == 'false') {
          _showError("Error fetching types: ${decodedResponse['message']}");
        } else {
          _showError("Unexpected response format.");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Failed to fetch types: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    print(message);
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
            getType();
          });
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
          });
          _fetchUserRole().then((_) {
            getType();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "วัสดุ",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.mali().fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),

        // actions: [
        //   if (userRole == 'Admin')
        //     IconButton(
        //       onPressed: () async {
        //         final result = await Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => const InsertPage()),
        //         );
        //         if (result != null && result == true) {
        //           getType(); // รีเฟรชข้อมูล
        //         }
        //       },
        //       icon: const Icon(Icons.add),
        //     ),
        // ],
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth < 600 ? 2 : 3,
                          childAspectRatio: 0.75,
                        ),
                        itemCount:
                            types.length + 2, // Add 1 for the report card
                        itemBuilder: (context, index) {
                          if (index == types.length) {
                            // Render report card
                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          // (context) => CheckoutReportPage(
                                          //   token: widget.token,
                                          // ),
                                          (context) => CheckoutMtReport(
                                            // token: widget.token,
                                          ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "รายงาน",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              GoogleFonts.mali().fontFamily,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (index == types.length + 1) {
                            // Render material consumption card

                            if (userRole == 'Admin') {
                              return Card(
                                margin: const EdgeInsets.all(10),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminPage(),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "สถานะการเบิกวัสดุ",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                GoogleFonts.mali().fontFamily,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Skip rendering the card if not admin
                              return const SizedBox.shrink();
                            }
                          } else {
                            // Render material type cards
                            final type = types[index];
                            final String name = type['mttype_name'] ?? '';

                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MaterialsPage(
                                            token: widget.token,
                                          ),
                                    ),
                                  );

                                  if (result != null) {
                                    if (result is String) {
                                      String newName = result;
                                      setState(() {
                                        type['eqt_name'] = newName;
                                      });
                                    }
                                  } else {
                                    getType(); //Reload data after delete.
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily:
                                              GoogleFonts.mali().fontFamily,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
