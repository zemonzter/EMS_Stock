import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditUnit extends StatefulWidget {
  final Map<String, dynamic> unit;

  const EditUnit({super.key, required this.unit});

  @override
  State<EditUnit> createState() => _EditUnitState();
}

class _EditUnitState extends State<EditUnit> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit['unit_name']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _deleteUnit(String unitId) async {
    String uri = "${baseUrl}delete_unit.php"; // Update with your PHP script
    try {
      final response = await http
          .post(Uri.parse(uri), body: {'unit_id': unitId})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          Navigator.pop(context, null);
        } else {
          // _showError("Failed to delete unit: ${decodedResponse['message']}");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      // _showError("Failed to delete unit: $e");
      Navigator.pop(context, null);
    }
  }

  Future<void> _updateUnitName(String unitId, String newName) async {
    String uri = "${baseUrl}update_unit.php"; // Update with your PHP script
    try {
      final response = await http
          .post(Uri.parse(uri), body: {'unit_id': unitId, 'unit_name': newName})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          Navigator.pop(context, newName);
        } else {
          // _showError("Failed to update unit: ${decodedResponse['message']}");
          Navigator.pop(context, newName);
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      // _showError("Failed to update unit: $e");
      Navigator.pop(context, newName);
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
          "แก้ไขหน่วยนับ",
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
                const SizedBox(height: 10),
                Text(
                  "ชื่อหน่วยนับ",
                  style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "ชื่อหน่วยนับ",
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
                      onPressed: () {
                        String newName = _nameController.text;
                        _updateUnitName(
                          widget.unit['unit_id'].toString(),
                          newName,
                        );
                      },
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
                                'ยืนยันการลบหน่วยนับ',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              content: Text(
                                'คุณแน่ใจหรือไม่ว่าต้องการลบหน่วยนับนี้?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    _deleteUnit(widget.unit['unit_id']);
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
                        'ลบ',
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
