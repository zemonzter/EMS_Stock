import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'models/dropdown_model.dart';
import 'models/dropdown_status.dart';

class InsertEq extends StatefulWidget {
  const InsertEq({super.key});

  @override
  State<InsertEq> createState() => _InsertEqState();
}

class _InsertEqState extends State<InsertEq> {
  TextEditingController eqtname = TextEditingController();
  TextEditingController userid = TextEditingController();
  TextEditingController eqmodel = TextEditingController();
  TextEditingController eqbrand = TextEditingController();
  TextEditingController eqserial = TextEditingController();
  TextEditingController eqstatus = TextEditingController();
  TextEditingController eqprice = TextEditingController();
  TextEditingController eqdate = TextEditingController();
  TextEditingController eqwarran = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? imagepath;
  String? imagename;
  String? imagedata;

  ImagePicker imagePicker = ImagePicker();

  Future<void> insertEq() async {
    print('insertEq called');

    final formState = _formKey.currentState; // เก็บ currentState

    print('formKey.currentState!.validate(): ${formState?.validate()}');

    if (formState != null &&
        formState.validate() &&
        selectedType != null &&
        selectedType!.isNotEmpty &&
        selectedStatus != null &&
        selectedStatus!.isNotEmpty) {
      try {
        String uri = "${baseUrl}insert_eq.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {
            "eqtname": selectedType,
            "userid": userid.text,
            "eqmodel": eqmodel.text,
            "eqbrand": eqbrand.text,
            "eqserial": eqserial.text,
            "eqstatus": selectedStatus,
            "eqprice": eqprice.text,
            "eqdate": eqdate.text,
            "eqwarran": eqwarran.text,
            "data":
                imagedata?.isNotEmpty == true
                    ? imagedata!
                    : "", // No change needed, you're already handling null correctly
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'เพิ่มข้อมูลครุภัณฑ์สำเร็จ',
              style: TextStyle(fontFamily: 'mali'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากรอกข้อมูลให้ครบถ้วน',
            style: TextStyle(fontFamily: 'mali'),
          ),
        ),
      );
      print("please fill all the details");
    }
  }

  Future<List<DropdownModel>> getPost() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}view_eqt.php"));
      final body = json.decode(response.body) as List;

      if (response.statusCode == 200) {
        return body.map((e) {
          final map = e as Map<String, dynamic>;
          return DropdownModel(eqtId: map["eqt_id"], eqtName: map["eqt_name"]);
        }).toList();
      }
    } on SocketException {
      throw Exception('No Internet connection');
    }
    throw Exception("Fetch Data Error");
  }

  Future<List<DropdownStatus>> getStatus() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}view_status.php"));
      final body = json.decode(response.body) as List;

      if (response.statusCode == 200) {
        return body.map((e) {
          final map = e as Map<String, dynamic>;
          return DropdownStatus(
            status_id: map["status_id"],
            status: map["status"],
          );
        }).toList();
      }
    } on SocketException {
      throw Exception('No Internet connection');
    }
    throw Exception("Fetch Data Error");
  }

  String? selectedStatus;
  var selectedType;

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
            "เพิ่มครุภัณฑ์",
            style: TextStyle(
              color: Colors.white,
              fontFamily: GoogleFonts.mali().fontFamily,
            ),
          ),
          backgroundColor: const Color(0xFF7E0101),
          toolbarHeight: 120,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: Responsive.isDesktop(context) ? 1000 : double.infinity,
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //dropdown button eq_type
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        FutureBuilder<List<DropdownModel>>(
                          future: getPost(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  label: Text(
                                    "ประเภทครุภัณฑ์",
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.mali().fontFamily,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  // Added validator
                                  if (value == null) {
                                    return 'กรุณาเลือกประเภทครุภัณฑ์';
                                  }
                                  return null;
                                },
                                borderRadius: BorderRadius.circular(18.0),
                                value: selectedType,
                                dropdownColor: Colors.deepPurple[100],
                                isExpanded: true,
                                hint: Text(
                                  "Select Item",
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                                items:
                                    snapshot.data!.map((e) {
                                      return DropdownMenuItem(
                                        value: e.eqtName.toString(),
                                        child: Text(e.eqtName.toString()),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedType = value;
                                  });
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
                    TextFormField(
                      controller: userid,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "ผู้ถือครอง",
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกข้อมูลผู้ถือครอง';
                        }
                        return null;
                      },
                    ), //user_id
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: eqbrand,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "ยี่ห้อ",
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกข้อมูลยี่ห้อ';
                        }
                        return null;
                      },
                    ), //eq_brand
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: eqmodel,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "รุ่นครุภัณฑ์",
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกข้อมูลรุ่นครุภัณฑ์';
                        }
                        return null;
                      },
                    ), //eq_model

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: eqserial,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "หมายเลขซีเรียล",
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกข้อมูลหมายเลขซีเรียล';
                        }
                        return null;
                      },
                    ), //eq_serial
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        FutureBuilder<List<DropdownStatus>>(
                          future: getStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  label: Text(
                                    "สถานะ",
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.mali().fontFamily,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'กรุณาเลือกสถานะ';
                                  }
                                  return null;
                                },
                                borderRadius: BorderRadius.circular(18.0),
                                value: selectedStatus,
                                dropdownColor: Colors.deepPurple[100],
                                isExpanded: true, //
                                hint: Text(
                                  "Select Status",
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                                items:
                                    snapshot.data!.map((e) {
                                      return DropdownMenuItem(
                                        value: e.status,
                                        child: Text(
                                          e.status,
                                          style: TextStyle(
                                            fontFamily:
                                                GoogleFonts.mali().fontFamily,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStatus = value;
                                  });
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
                    TextFormField(
                      controller: eqprice,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "ราคา",
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        // เพิ่ม validator
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกข้อมูลราคา';
                        }
                        return null;
                      },
                    ), //eq_price
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: eqdate,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "วันที่ซื้อ",
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        // เพิ่ม validator
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกข้อมูลวันที่ซื้อ';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? datetime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                        );

                        if (datetime != null) {
                          String formattedDate = DateFormat(
                            'dd-MM-yyyy',
                          ).format(datetime);

                          setState(() {
                            eqdate.text = formattedDate;
                          });
                        }
                      },
                    ), //eq_date
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: eqwarran,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        label: Text(
                          "ระยะเวลาประกัน",
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกข้อมูลระยะเวลาประกัน';
                        }
                        return null;
                      },
                    ), //eq_warran
                    const SizedBox(height: 20),

                    imagepath != null
                        ? Image.file(imagepath!)
                        : Image.asset('assets/images/default.jpg'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        getImage();
                      },
                      child: Text(
                        'Choose image',
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ),

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
                              insertEq();
                            },
                            child: Text(
                              'ยืนยัน',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: GoogleFonts.mali().fontFamily,
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
                                fontFamily: GoogleFonts.mali().fontFamily,
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
