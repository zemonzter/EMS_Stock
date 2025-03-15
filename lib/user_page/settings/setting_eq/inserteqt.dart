import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController eqtname = TextEditingController();

  Future<void> insertType() async {
    if (_formKey.currentState!.validate()) {
      String uri = "${baseUrl}insert.php";
      try {
        final response = await http
            .post(Uri.parse(uri), body: {"eqtname": eqtname.text})
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final dynamic decodedResponse = json.decode(response.body);
          if (decodedResponse is Map && decodedResponse['success'] == 'true') {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to insert type.')),
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
      // ฟอร์มไม่ถูกต้อง
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'เพิ่มประเภทครุภัณฑ์',
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
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: eqtname,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          'เพิ่มประเภทครุภัณฑ์',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกประเภทครุภัณฑ์';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                              insertType();
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
      ),
    );
  }
}
