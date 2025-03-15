import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InsertMaintenanceStatus extends StatefulWidget {
  const InsertMaintenanceStatus({super.key});

  @override
  State<InsertMaintenanceStatus> createState() =>
      _InsertMaintenanceStatusState();
}

class _InsertMaintenanceStatusState extends State<InsertMaintenanceStatus> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController mainten_status = TextEditingController();

  Future<void> insertMaintenanceStatus() async {
    if (_formKey.currentState!.validate()) {
      // ตรวจสอบความถูกต้องของฟอร์ม
      try {
        String uri = "${baseUrl}insert_maintenance_status.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {"mainten_status": mainten_status.text},
        );

        var response = jsonDecode(res.body);
        if (res.statusCode == 200) {
          if (response['success'] == 'true') {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to insert status.')),
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
          "เพิ่มสถานะการแจ้งซ่อม",
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
                    controller: mainten_status,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "สถานะการแจ้งซ่อม",
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
                            insertMaintenanceStatus();
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
