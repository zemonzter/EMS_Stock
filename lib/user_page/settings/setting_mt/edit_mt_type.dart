import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditMTType extends StatefulWidget {
  final Map<String, dynamic> mtType;

  const EditMTType({super.key, required this.mtType});

  @override
  State<EditMTType> createState() => _EditMTTypeState();
}

class _EditMTTypeState extends State<EditMTType> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mtType['mttype_name']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _deletemtType(String mttId) async {
    String uri = "${baseUrl}delete_mt_type.php";
    try {
      final response = await http
          .post(Uri.parse(uri), body: {'mttype_id': mttId})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          Navigator.pop(context, null);
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

  Future<void> _updatemtTypeName(String mttId, String newName) async {
    String uri = "${baseUrl}update_mt_type.php";
    try {
      final response = await http
          .post(
            Uri.parse(uri),
            body: {'mttype_id': mttId, 'mttype_name': newName},
          )
          .timeout(const Duration(seconds: 10));
      var decodedResponse = json.decode(response.body);

      if (response.statusCode == 200 && decodedResponse['success'] == 'true') {
        Navigator.pop(context, newName);
      } else {
        _showError("Failed to update: ${decodedResponse['message']}");
      }
    } catch (e) {
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
          "แก้ไขประเภทวัสดุ",
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
                  "ชื่อประเภทวัสดุ",
                  style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "ชื่อประเภทวัสดุ",
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String newName = _nameController.text;
                        _updatemtTypeName(
                          widget.mtType['mttype_id'].toString(),
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
                                'ยืนยันการลบประเภทวัสดุ',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              content: Text(
                                'คุณแน่ใจหรือไม่ว่าต้องการลบประเภทวัสดุนี้?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    _deletemtType(widget.mtType['mttype_id']);
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
