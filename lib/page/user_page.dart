import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/eqt_page/test/insert_eq.dart';
import 'package:ems_condb/eqt_page/util/insert_eq.dart';
import 'package:ems_condb/login.dart';
import 'package:ems_condb/mt_page/checkout/checkout_mt_report.dart';
import 'package:ems_condb/mt_page/checkout/checkout_report.dart';
import 'package:ems_condb/mt_page/insert_mt.dart';
import 'package:ems_condb/user_page/import/import.dart';
import 'package:ems_condb/user_page/import/import_eq.dart';
import 'package:ems_condb/user_page/setting.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  final String token;
  const UserPage({super.key, required this.token});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String userName = '';
  String userRole = '';

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

  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(
      Uri.parse('https://api.rmutsv.ac.th/elogin/token/${widget.token}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      // _saveUserDataToDatabase(data);
      return data;
    } else {
      throw Exception(
        'Failed to retrieve user data. Status code: ${response.statusCode}',
      );
    }
  }

  void _showImportDataDialog(BuildContext context) {
    if (userRole != 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permission denied: Only admin can import data',
            style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'อัปโหลดข้อมูล',
            style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
          ),
          content: Text(
            'เลือกประเภทข้อมูลเพื่ออัปโหลด:',
            style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24.0,
            20.0,
            24.0,
            0.0,
          ), // ปรับ padding ของ content
          actions: <Widget>[
            Column(
              // ใช้ Column แทน actions
              mainAxisSize:
                  MainAxisSize.min, // ให้ Column มีขนาดเล็กที่สุดเท่าที่จะทำได้
              children: <Widget>[
                TextButton(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ครุภัณฑ์',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                  ), // จัดข้อความให้อยู่ซ้าย
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImportEqPage(),
                      ),
                    );
                  },
                ),
                TextButton(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'วัสดุ',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                  ), // จัดข้อความให้อยู่ซ้าย
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ImportPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserData()
        .then((userData) {
          setState(() {
            userName = userData['name'] ?? 'User';
          });
          _fetchUserRole().then((_) {});
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
          });
          _fetchUserRole().then((_) {});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final userData = snapshot.data!;

            // Check for expected keys before accessing
            final expectedKeys = ['username', 'name', 'email', 'type', 'token'];
            for (var key in expectedKeys) {
              if (!userData.containsKey(key)) {
                print('Warning: Key "$key" missing in user data');
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      // color: Colors.grey[700],
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red[300]!, Colors.red[700]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 25),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (userRole == 'Admin')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.settings,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const SettingScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                  'assets/images/user.png',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'E-Passport: ${userData['username']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                  Text(
                                    'Name: ${userData['name']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                  Text(
                                    'Email: ${userData['email']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                  Text(
                                    'Type: ${userData['type']}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  // Text('Token: ${userData['token']}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // floatingActionButton: FloatingActionButton(
                    //   onPressed: () {
                    //     // Handle settings button press
                    //   },
                    //   child: Icon(Icons.settings),
                    // ),
                    const SizedBox(height: 16),

                    Container(
                      // padding: const EdgeInsets.only(left: 25),
                      margin: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (userRole == 'Admin' || userRole == 'Officer')
                            GestureDetector(
                              onTap: () {
                                _showImportDataDialog(context);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.note_add, size: 30),
                                  SizedBox(width: 10),
                                  Text(
                                    'นำเข้าข้อมูล',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (userRole == 'Admin' || userRole == 'Officer')
                            const SizedBox(height: 25),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutMtReport(),
                                ),
                              );
                              print('Export data tapped');
                            },
                            child: Row(
                              children: [
                                Icon(Icons.arrow_circle_up, size: 30),
                                SizedBox(width: 10),
                                Text(
                                  'ส่งออกข้อมูล',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          if (userRole == 'Admin' || userRole == 'Officer')
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AddEquipmentPage(),
                                  ),
                                );
                                print('Add Equipment!');
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.add_to_queue, size: 30),
                                  const SizedBox(width: 10),
                                  Text(
                                    'เพิ่มครุภัณฑ์',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (userRole == 'Admin' || userRole == 'Officer')
                            const SizedBox(height: 25),
                          if (userRole == 'Admin' || userRole == 'Officer')
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const InsertMT(),
                                  ),
                                );
                                print('Add Material!');
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.post_add, size: 30),
                                  const SizedBox(width: 10),
                                  Text(
                                    'เพิ่มวัสดุ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (userRole == 'Admin' || userRole == 'Officer')
                            const SizedBox(height: 25),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                              print('Logout!');
                            },
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 30),
                                SizedBox(width: 10),
                                Text(
                                  'ลงชื่อออก',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Return an empty container or any other widget as a fallback
          return const SizedBox();
        },
      ),
    );
  }
}
