import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateEquipment extends StatefulWidget {
  final String eqName;
  final String brand;
  // final String token;
  const UpdateEquipment({
    super.key,
    required this.eqName,
    // required this.token,
    required this.brand,
  });

  @override
  State<UpdateEquipment> createState() => _UpdateEquipmentState();
}

class _UpdateEquipmentState extends State<UpdateEquipment> {
  late TextEditingController _statusController;

  File? imagepath;
  String? imagename;
  String? imagedata;
  ImagePicker imagePicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.brand}  ${widget.eqName}',
          style: TextStyle(fontFamily: 'mali'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("ประเภทครุภัณฑ์"),
            const SizedBox(height: 10),
            TextFormField(
              // controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                labelText: "ชื่อประเภทครุภัณฑ์",
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
                  // getImage();
                },
                child: const Text('Choose image'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // String newName = _nameController.text;
                    // _updateEqTypeName(
                    //   widget.eqType['eqt_id'].toString(),
                    //   newName,
                    // );
                  },
                  child: const Text("แก้ไข"),
                ),
                const SizedBox(width: 10),
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
                                // _deleteEqType(widget.eqType['eqt_id']);
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
}
