import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMember extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditMember({super.key, required this.userData});

  @override
  _EditMemberState createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late String _role;
  List<String> _roles = []; // เพิ่มตัวแปรสำหรับเก็บข้อมูลบทบาท

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.userData['user_name'],
    );
    _emailController = TextEditingController(
      text: widget.userData['user_email'],
    );
    _role = widget.userData['user_role'];
    _fetchRoles(); // เรียกฟังก์ชันดึงข้อมูลบทบาท
  }

  Future<void> _fetchRoles() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}view_role.php"),
      ); // สร้าง API สำหรับดึงข้อมูลบทบาท
      if (response.statusCode == 200) {
        final List<dynamic> decodedResponse = json.decode(response.body);
        setState(() {
          _roles =
              decodedResponse.map((item) => item['role'].toString()).toList();
        });
      } else {
        _showError("Failed to fetch roles: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Failed to fetch roles: $e");
    }
  }

  Future<void> _updateMember() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('Sending user_id: ${widget.userData['user_id']}');
        var response = await http.post(
          Uri.parse("${baseUrl}update_member.php"),
          body: {
            'user_id': widget.userData['user_id'],
            'user_name': _usernameController.text,
            'user_email': _emailController.text,
            'user_role': _role,
          },
        );

        var decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == 'true') {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${decodedResponse['message']}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _deleteMember(String userId) async {
    String uri = "${baseUrl}delete_member.php";
    try {
      final response = await http
          .post(Uri.parse(uri), body: {'user_id': userId})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          Navigator.pop(context, true);
        } else {
          _showError("Failed to delete type: ${decodedResponse['message']}");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Failed to delete type: $e");
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "แก้ไขสมาชิก",
          style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  labelStyle: TextStyle(
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่ชื่อผู้ใช้';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  labelStyle: TextStyle(
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่อีเมล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                items:
                    _roles.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'บทบาท',
                  labelStyle: TextStyle(
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _updateMember,
                    child: Text(
                      'บันทึกการแก้ไข',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'ยืนยันการลบผู้ใช้',
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                            content: Text(
                              'คุณแน่ใจหรือไม่ว่าต้องการลบผู้ใช้นี้?',
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  _deleteMember(widget.userData['user_id']);
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'ยืนยัน',
                                  style: TextStyle(
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'ยกเลิก',
                                  style: TextStyle(
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                    ),
                    child: Text(
                      'ลบผู้ใช้',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Fonts.Fontnormal.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
