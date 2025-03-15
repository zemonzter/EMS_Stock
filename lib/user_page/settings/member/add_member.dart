import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/mt_page/util/dropdown_role.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final _formKey = GlobalKey<FormState>(); // เพิ่ม GlobalKey สำหรับ Form
  TextEditingController user_name = TextEditingController();
  TextEditingController user_email = TextEditingController();

  File? imagepath;
  String? imagename;
  String? imagedata;

  ImagePicker imagePicker = ImagePicker();

  Future<void> insertUser() async {
    if (_formKey.currentState!.validate() && selectedRole != null) {
      try {
        String uri = "${baseUrl}insert_user.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {
            "user_name": user_name.text,
            "user_email": user_email.text,
            "user_role": selectedRole,
            "data": imagedata?.isNotEmpty == true ? imagedata : "",
            "name": imagename ?? "",
          },
        );

        var response = jsonDecode(res.body);
        if (response['success'] == 'true') {
          print("Record inserted successfully");
          Navigator.pop(context, true);
        } else {
          print("Error inserting record");
        }
      } catch (e) {
        print(e);
        Navigator.pop(context, true);
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      // );
      print("please fill all the details");
    }
  }

  Future<List<DropdownRoleModel>> getRole() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}view_role.php"));
      final body = json.decode(response.body) as List;

      if (response.statusCode == 200) {
        return body.map((e) {
          final map = e as Map<String, dynamic>;
          return DropdownRoleModel(role_id: map["role_id"], role: map["role"]);
        }).toList();
      }
    } on SocketException {
      throw Exception('No Internet connection');
    }
    throw Exception("Fetch Data Error");
  }

  String? selectedRole;

  Future<void> getImage() async {
    var getimage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (getimage == null) return;

    setState(() {
      imagepath = File(getimage.path);
      imagename = getimage.path.split('/').last;
      imagedata = base64Encode(imagepath!.readAsBytesSync());
      print(imagepath);
      print(imagename);
      print(imagedata);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "เพิ่มสมาชิก",
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
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Form(
                  // ห่อ Column ด้วย Form
                  key: _formKey, // กำหนด GlobalKey ให้ Form
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: user_name,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          label: Text(
                            "ชื่อสมาชิก",
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        ),
                        validator: (value) {
                          // เพิ่ม validator
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกชื่อสมาชิก';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: user_email,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          label: Text(
                            "อีเมล์",
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        ),
                        validator: (value) {
                          // เพิ่ม validator
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกอีเมล์';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          FutureBuilder<List<DropdownRoleModel>>(
                            future: getRole(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    label: Text(
                                      "สิทธิ์การใช้งาน",
                                      style: TextStyle(
                                        fontFamily: Fonts.Fontnormal.fontFamily,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(18.0),
                                  value: selectedRole,
                                  dropdownColor: Colors.deepPurple[100],
                                  isExpanded: true,
                                  hint: Text(
                                    "เลือกสิทธิ์การใช้งาน",
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                      fontSize: 14,
                                    ),
                                  ),
                                  items:
                                      snapshot.data!.map((e) {
                                        return DropdownMenuItem(
                                          value: e.role.toString(),
                                          child: Text(
                                            e.role.toString(),
                                            style: TextStyle(
                                              fontFamily:
                                                  Fonts.Fontnormal.fontFamily,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRole = value;
                                    });
                                  },
                                  validator: (value) {
                                    // เพิ่ม validator
                                    if (value == null) {
                                      return 'กรุณาเลือกสิทธิ์การใช้งาน';
                                    }
                                    return null;
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      imagepath != null
                          ? Image.file(imagepath!)
                          : Image.asset(
                            'assets/images/user.png',
                            width: Responsive.isDesktop(context) ? 300 : 200,
                            height: Responsive.isDesktop(context) ? 300 : 200,
                          ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          getImage();
                        },
                        child: Text(
                          'เลือกรูปภาพ',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
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
                                insertUser();
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
      ),
    );
  }
}
