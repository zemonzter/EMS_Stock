import 'package:ems_condb/api_config.dart';
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
  List<dynamic>? _userData; // เก็บข้อมูลผู้ใช้ที่ดึงมา

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ดึงข้อมูลผู้ใช้เมื่อเริ่มต้น
  }

  Future<void> _fetchUserData() async {
    String url = "${baseUrl}view_user.php";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
        });
      } else {
        print('Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful')));

          // ตรวจสอบว่าข้อมูลตรงกับผู้ใช้ในตารางหรือไม่
          _checkUserData();
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

  void _checkUserData() {
    if (_userData != null) {
      for (var user in _userData!) {
        if (user['user_name'] == _username) {
          // พบข้อมูลผู้ใช้ที่ตรงกัน
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('User Data Match'),
                  content: Text('User name: ${user['user_name']}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
          return; // หยุดการทำงานเมื่อพบข้อมูลที่ตรงกัน
        }
      }
      // ไม่พบข้อมูลผู้ใช้ที่ตรงกัน
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('User Data Not Found'),
              content: const Text('User data not found in the table.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
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
                        child: const Text('Login'),
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
