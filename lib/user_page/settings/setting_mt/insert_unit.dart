import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InsertUnit extends StatefulWidget {
  const InsertUnit({super.key});

  @override
  State<InsertUnit> createState() => _InsertUnitState();
}

class _InsertUnitState extends State<InsertUnit> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController unit_name = TextEditingController();

  Future<void> insertUnit() async {
    if (_formKey.currentState!.validate()) {
      // ตรวจสอบความถูกต้องของฟอร์ม
      try {
        String uri = "${baseUrl}insert_unit.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {"unit_name": unit_name.text},
        );

        var response = jsonDecode(res.body);
        if (res.statusCode == 200) {
          if (response['success'] == 'true') {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to insert unit.')),
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('HTTP request failed.')));
        }
      } catch (e) {
        if (_formKey.currentState!.validate() != '') {
          Navigator.pop(context, true);
        } else {
          Navigator.pop(context, true);
        }
      }
    } else {
      // ฟอร์มไม่ถูกต้อง, ข้อความแจ้งเตือนจะแสดงโดย validator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "เพิ่มหน่วยนับ",
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
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
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: unit_name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "หน่วยนับ",
                        style: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกข้อมูล';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
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
                            insertUnit();
                          },
                          child: Text(
                            'ยืนยัน',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
