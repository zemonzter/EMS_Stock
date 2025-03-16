import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems_condb/api_config.dart';

class EditMtPage extends StatefulWidget {
  final String id;
  final String name;
  final String stock;
  final String unit;
  final String imageUrl;
  final String url;
  final Function(String, String, String)? onUpdate;

  const EditMtPage({
    Key? key,
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
    required this.imageUrl,
    required this.url,
    this.onUpdate,
  }) : super(key: key);

  @override
  _EditMtPageState createState() => _EditMtPageState();
}

class _EditMtPageState extends State<EditMtPage> {
  late TextEditingController _nameController;
  late TextEditingController _stockController;
  late TextEditingController _unitController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _stockController = TextEditingController(text: widget.stock);
    _unitController = TextEditingController(text: widget.unit);
    _urlController = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _showDialog(
    BuildContext context,
    String title,
    String content, {
    bool shouldPop = false,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ตกลง',
                style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (shouldPop) {
                  Navigator.of(context).pop(); // Pop the Edit page
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMT(String mtId) async {
    String uri = "${baseUrl}delete_mt.php";
    try {
      final response = await http
          .post(Uri.parse(uri), body: {'mt_id': mtId})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          if (mounted) {
            _showDialog(
              context,
              "เสร็จสิ้น",
              "วัสดุถูกลบแล้ว",
              shouldPop: true, // Pop the page after deletion
            );
          }
        } else {
          if (mounted) {
            _showDialog(
              context,
              "Error",
              "Failed to delete material: ${decodedResponse['message']}",
            );
          }
        }
      } else {
        if (mounted) {
          _showDialog(
            context,
            "Error",
            "HTTP request failed: ${response.statusCode}",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showDialog(context, "Error", "Failed to delete material: $e");
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขข้อมูลวัสดุ',
          style: TextStyle(
            color: Colors.black,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              widget.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.error)),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อวัสดุ',
                labelStyle: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
            ),
            TextFormField(
              controller: _stockController,
              decoration: InputDecoration(
                labelText: 'จำนวน',
                labelStyle: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: 'หน่วยนับ',
                labelStyle: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
            ),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'ลิงค์เว็บไซต์',
                labelStyle: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _saveChanges();
                  },
                  child: Text('บันทึกข้อมูล'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'ยืนยันการลบประเภทครุภัณฑ์',
                            style: TextStyle(fontSize: 20),
                          ),
                          content: const Text(
                            'คุณแน่ใจหรือไม่ว่าต้องการลบประเภทครุภัณฑ์นี้?',
                            style: TextStyle(fontSize: 12),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                _deleteMT(widget.id); // Use widget.id directly
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
                    'ลบ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _unitController.text.isEmpty) {
      if (mounted) {
        _showDialog(context, "ข้อผิดพลาด", 'กรุณากรอกข้อมูลภายในฟอร์ม');
      }
      return;
    }

    final Map<String, String> data = {
      'id': widget.id,
      'name': _nameController.text,
      'stock': _stockController.text,
      'unit': _unitController.text,
      'url': _urlController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_mt.php'),
        body: data,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == 'true') {
          if (mounted) {
            _showDialog(
              context,
              "เสร็จสิ้น",
              "วัสดุได้รับการอัปเดตข้อมูล!",
              shouldPop: true,
            );

            widget.onUpdate?.call(
              _nameController.text,
              _stockController.text,
              _unitController.text,
            );
          }
        } else {
          if (mounted) {
            _showDialog(
              context,
              "Error",
              "Failed to update material: ${jsonResponse['error']}",
            );
          }
        }
      } else {
        if (mounted) {
          _showDialog(context, "Error", "Server error: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        _showDialog(context, "Error", "Exception: $e");
      }
    }
  }
}
