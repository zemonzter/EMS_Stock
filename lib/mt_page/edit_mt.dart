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
  // final VoidCallback? onRefresh; // Remove this - we're passing data back now.
  // Use a callback that accepts the updated data.
  final Function(String, String, String)? onUpdate;

  const EditMtPage({
    Key? key,
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
    required this.imageUrl,
    required this.url,
    this.onUpdate, // Include it in the constructor
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
    // Add optional parameter
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
                Navigator.of(context).pop(); // Always pop the dialog
                if (shouldPop) {
                  // Only pop the Edit page if shouldPop is true
                  //  Navigator.of(context).pop(); // Don't pop here.  Pop AFTER onRefresh.
                }
              },
            ),
          ],
        );
      },
    );
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
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('บันทึกข้อมูล'),
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
        // Check mounted before showing the dialog
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

            // Call onUpdate with the *new* values.  This is KEY.
            widget.onUpdate?.call(
              _nameController.text,
              _stockController.text,
              _unitController.text,
            );

            Navigator.pop(context); // Pop happens AFTER onRefresh.
          }
        } else {
          if (mounted) {
            // Check mounted before showing dialog
            _showDialog(
              context,
              "Error",
              "Failed to update material: ${jsonResponse['error']}",
            );
          }
        }
      } else {
        if (mounted) {
          // Check mounted before showing dialog
          _showDialog(context, "Error", "Server error: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        // Check mounted before showing dialog
        _showDialog(context, "Error", "Exception: $e");
      }
    }
  }
}
