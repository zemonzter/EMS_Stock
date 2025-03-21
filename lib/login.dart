import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/admin_tab.dart';
import 'package:ems_condb/util/tab_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  String? _token;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final response = await http.post(
        Uri.parse('https://api.rmutsv.ac.th/elogin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _username,
          'password': _password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          _token = data['token'];

          // ดึงข้อมูลผู้ใช้จาก token
          final userName = await _fetchAndShowUserData(_token!);

          // ตรวจสอบ username กับฐานข้อมูล
          if (userName != null) {
            await _verifyUsername(userName);
          }

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => TabMenuPage(token: _token!),
          //   ),
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API request failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้และแสดง pop-up (return username)
  Future<String?> _fetchAndShowUserData(String token) async {
    final userDataResponse = await http.get(
      Uri.parse('https://api.rmutsv.ac.th/elogin/token/$token'),
    );

    if (userDataResponse.statusCode == 200) {
      final Map<String, dynamic> userData = jsonDecode(
        utf8.decode(userDataResponse.bodyBytes),
      );
      final userName = userData['name'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เข้าสู่ระบบสำเร็จ ยินดีต้อนรับ, $userName')),
      );

      return userName; // return username
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch user data.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // ฟังก์ชันตรวจสอบ username กับฐานข้อมูล
  Future<void> _verifyUsername(String userName) async {
    String uri = "${baseUrl}view_user.php";
    try {
      var response = await http.get(Uri.parse(uri));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final userExists = data.any((user) => user['user_name'] == userName);

        if (userExists) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('ผู้ใช้ "$userName" found in the database.'),
          //   ),
          // );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // builder: (context) => TabMenuPage(token: _token!),
              builder: (context) => TabbedNavbarPage(token: _token!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ขออภัย ไม่พบข้อมูลผู้ใช้.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to database.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7E0101),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.25,
              ),
              Container(
                width: 500,
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.0),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'E-Passport',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter your E-Passport';
                          }
                          return null;
                        },
                        onSaved: (value) => _username = value!,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter your Password';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('เข้าสู่ระบบ'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
