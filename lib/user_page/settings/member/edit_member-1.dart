import 'package:ems_condb/api_config.dart';
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
  }

  Future<void> _updateMember() async {
    if (_formKey.currentState!.validate()) {
      try {
        print(
          'Sending user_id: ${widget.userData['user_id']}',
        ); // เพิ่มบรรทัดนี้

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
          Navigator.pop(context, true); // Return true to refresh list
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
      appBar: AppBar(title: const Text("แก้ไขสมาชิก")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่ชื่อผู้ใช้';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'อีเมล'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่อีเมล';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _role,
                items:
                    <String>['Admin', 'User', 'Engineer', 'Officer'].map((
                      String value,
                    ) {
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
                decoration: const InputDecoration(labelText: 'บทบาท'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _updateMember,
                    child: const Text('บันทึกการแก้ไข'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('ยืนยันการลบผู้ใช้'),
                            content: const Text(
                              'คุณแน่ใจหรือไม่ว่าต้องการลบผู้ใช้นี้?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  _deleteMember(widget.userData['user_id']);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('ยืนยัน'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('ยกเลิก'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                    ),
                    child: const Text(
                      'ลบผู้ใช้',
                      style: TextStyle(color: Colors.white),
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
