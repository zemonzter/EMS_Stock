import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditRole extends StatefulWidget {
  final Map<String, dynamic> role;

  const EditRole({super.key, required this.role});

  @override
  State<EditRole> createState() => _EditRoleState();
}

class _EditRoleState extends State<EditRole> {
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.role['role']);
    _descriptionController = TextEditingController(
      text: widget.role['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _roleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateRole() async {
    String uri = "${baseUrl}update_role.php";
    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {
          'role_id': widget.role['role_id'].toString(),
          'role': _roleController.text,
          'description': _descriptionController.text,
        },
      );
      var decodedResponse = json.decode(response.body);

      if (response.statusCode == 200 && decodedResponse['success'] == 'true') {
        Navigator.pop(context, true);
      } else {
        _showError("Failed to update role: ${decodedResponse['message']}");
      }
    } catch (e) {
      _showError("Failed to update role: $e");
    }
  }

  Future<void> _deleteRole() async {
    String uri = "${baseUrl}delete_role.php";
    try {
      final response = await http.post(
        Uri.parse(uri),
        body: {'role_id': widget.role['role_id'].toString()},
      );
      var decodedResponse = json.decode(response.body);

      if (response.statusCode == 200 && decodedResponse['success'] == 'true') {
        Navigator.pop(context, true);
      } else {
        _showError("Failed to delete role: ${decodedResponse['message']}");
      }
    } catch (e) {
      _showError("Failed to delete role: $e");
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
          "แก้ไขสิทธิ์การใช้งาน",
          style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
        ),
      ),
      body: Center(
        child: SizedBox(
          width:
              Responsive.isDesktop(context)
                  ? 1000
                  : Responsive.isTablet(context)
                  ? 700
                  : double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // const SizedBox(height: 10),
                // Text(
                //   "ชื่อสิทธิ์",
                //   style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                // ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "ชื่อสิทธิ์",
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                ),
                // const SizedBox(height: 20),
                // Text(
                //   "คำอธิบาย",
                //   style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                // ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "คำอธิบาย",
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
                      onPressed: _updateRole,
                      child: Text(
                        "แก้ไข",
                        style: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
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
                                'ยืนยันการลบสิทธิ์',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              content: Text(
                                'คุณแน่ใจหรือไม่ว่าต้องการลบสิทธิ์นี้?',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    _deleteRole();
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
                        "ลบ",
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
      ),
    );
  }
}
