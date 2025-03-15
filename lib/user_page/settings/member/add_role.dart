import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddRole extends StatefulWidget {
  const AddRole({super.key});

  @override
  State<AddRole> createState() => _AddRoleState();
}

class _AddRoleState extends State<AddRole> {
  TextEditingController role = TextEditingController();
  TextEditingController description = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> addRole() async {
    // if (role.text != '' || description.text != '') {
    if (_formKey.currentState!.validate() &&
        role.text != null &&
        description.text != null) {
      try {
        String uri = "${baseUrl}insert_role.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {"role": role.text, "description": description.text},
        );

        var response = jsonDecode(res.body);
        if (response['success'] == 'true') {
          print("Record inserted successfully");
          Navigator.pop(context, true);
        } else {
          print("Error inserting record");
        }
      } catch (e) {
        // print(e);
        Navigator.pop(context, true);
      }
    } else {
      // print("please fill all the details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "เพิ่มสถานะสมาชิก",
            style: TextStyle(
              color: Colors.white,
              fontFamily: Fonts.Fontnormal.fontFamily,
            ),
          ),
          backgroundColor: const Color(0xFF7E0101),
          toolbarHeight: 120,
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
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: role,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "สถานะ",
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกสถานะ';
                        }
                        return null;
                      },
                    ), //user_id
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: description,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "คำอธิบาย",
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกคำอธิบาย';
                        }
                        return null;
                      },
                    ), //eq_brand
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
                              addRole();
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
