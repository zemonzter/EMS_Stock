import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class InsertEqType extends StatefulWidget {
  const InsertEqType({super.key});

  @override
  State<InsertEqType> createState() => _InsertEqTypeState();
}

class _InsertEqTypeState extends State<InsertEqType> {
  TextEditingController eqtname = TextEditingController();

  File? imagepath;
  String? imagename;
  String? imagedata;

  ImagePicker imagePicker = ImagePicker();

  Future<void> _insertEq(BuildContext context) async {
    // เพิ่ม BuildContext
    String uri = "${baseUrl}insert_eq_type.php";
    try {
      final response = await http
          .post(
            Uri.parse(uri),
            body: {
              "eqtname": eqtname.text,
              "data": imagedata?.isNotEmpty ?? false ? imagedata : "",
              "name": imagename ?? '',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          // เพิ่มสำเร็จ
          Navigator.pop(context, true); // ส่ง true กลับไปเพื่อบอกว่าเพิ่มสำเร็จ
        } else {
          // เพิ่มล้มเหลว
          // _showError(context, "Failed to insert type: ${decodedResponse['message']}");
        }
      } else {
        _showError(context, "HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.pop(context, true);
    }
  }

  Future<void> getImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        setState(() {
          imagepath = File(pickedFile.path);
          imagename = pickedFile.path.split('/').last;
          imagedata = base64Encode(imagepath!.readAsBytesSync());
          print(imagepath);
          print(imagename);
          print(imagedata);
        });
      } catch (e) {
        _showError(context, "Failed to encode image: $e");
      }
    } else {
      print("No image selected.");
    }
  }

  void _showError(BuildContext context, String message) {
    // เพิ่ม BuildContext
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
        title: const Text(
          "เพิ่มประเภทครุภัณฑ์",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: eqtname,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                label: const Text("ประเภทครุภัณฑ์"),
              ),
            ),
            const SizedBox(height: 20),
            imagepath != null
                ? Image.file(imagepath!)
                : Image.asset('assets/images/default.jpg'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  getImage();
                },
                child: const Text('Choose image'),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      _insertEq(context); // ส่ง BuildContext
                    },
                    child: const Text(
                      'ยืนยัน',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('ยกเลิก'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
