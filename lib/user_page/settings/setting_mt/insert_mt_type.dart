import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InsertMtType extends StatefulWidget {
  const InsertMtType({super.key});

  @override
  State<InsertMtType> createState() => _InsertMtTypeState();
}

class _InsertMtTypeState extends State<InsertMtType> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController mttype_name = TextEditingController();

  Future<void> insertMt() async {
    if (_formKey.currentState!.validate()) {
      try {
        String uri = "${baseUrl}insert_mt_type.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {
            "mttype_name": mttype_name.text, //ตัวหน้าต้องตรงกับชื่อ backend
          },
        );

        var response = jsonDecode(res.body);
        if (response.statusCode == 200) {
          final dynamic decodedResponse = json.decode(response.body);
          if (decodedResponse is Map && decodedResponse['success'] == 'true') {
            // เพิ่มสำเร็จ
            Navigator.pop(
              context,
              true,
            ); // ส่ง true กลับไปเพื่อบอกว่าเพิ่มสำเร็จ
          } else {
            // เพิ่มล้มเหลว
          }
        } else {
          // HTTP request failed
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "เพิ่มประเภทวัสดุ",
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
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: mttype_name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "ประเภทวัสดุ",
                        style: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกประเภทวัสดุ';
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
                            insertMt();
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
