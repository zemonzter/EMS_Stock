import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'util/dropdown_mttype.dart';

class InsertMT extends StatefulWidget {
  const InsertMT({super.key});

  @override
  State<InsertMT> createState() => _InsertMTState();
}

class _InsertMTState extends State<InsertMT> {
  TextEditingController mttype = TextEditingController();
  TextEditingController mtname = TextEditingController();
  TextEditingController unitid = TextEditingController();
  TextEditingController mtstock = TextEditingController();
  TextEditingController unitprice = TextEditingController();
  TextEditingController mtprice = TextEditingController();
  TextEditingController mtdate = TextEditingController();
  TextEditingController mtlink = TextEditingController();

  File? imagepath;
  String? imagename;
  String? imagedata;
  final _formKey = GlobalKey<FormState>();

  ImagePicker imagePicker = ImagePicker();

  Future<void> insertMT() async {
    final formState = _formKey.currentState;

    if (formState != null &&
        formState.validate() &&
        selectedMttype != null &&
        selectedMttype.isNotEmpty
    // &&
    // selectedUnit != null &&
    // selectedUnit.isNotEmpty
    ) {
      try {
        String uri = "${baseUrl}insert_mt.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {
            "mttype": selectedMttype,
            "mtname": mtname.text,
            "unitid": unitid.text,
            "mtstock": mtstock.text,
            "unitprice": unitprice.text,
            "mtprice": mtprice.text,
            "mtdate": mtdate.text,
            "mtlink": mtlink.text,
            "data":
                imagedata?.isNotEmpty == true
                    ? imagedata
                    : "", // Handle potential null for imagedata
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
              'เพิ่มข้อมูลวัสดุสำเร็จ',
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

  Future<List<DropdownMttypeModel>> getMTType() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}view_mttype.php"));
      final body = json.decode(response.body) as List;

      if (response.statusCode == 200) {
        return body.map((e) {
          final map = e as Map<String, dynamic>;
          return DropdownMttypeModel(
            mttypeId: map["mttype_id"],
            mttypeName: map["mttype_name"],
          );
        }).toList();
      }
    } on SocketException {
      throw Exception('No Internet connection');
    }
    throw Exception("Fetch Data Error");
  }

  // Future<List<DropdownUnitModel>> getUnit() async {
  //   try {
  //     final response = await http.get(Uri.parse("${baseUrl}view_unit.php"));
  //     final body = json.decode(response.body) as List;

  //     if (response.statusCode == 200) {
  //       return body.map((e) {
  //         final map = e as Map<String, dynamic>;
  //         return DropdownUnitModel(
  //           unitId: map["unit_id"],
  //           unitName: map["unit_name"],
  //         );
  //       }).toList();
  //     }
  //   } on SocketException {
  //     throw Exception('No Internet connection');
  //   }
  //   throw Exception("Fetch Data Error");
  // }

  var selectedMttype;
  // var selectedUnit;

  Future<void> getImage() async {
    var getimage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (getimage == null) return; // Early return if no image selected
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
            "เพิ่มวัสดุ",
            style: TextStyle(
              color: Colors.white,
              fontFamily: GoogleFonts.mali().fontFamily,
            ),
          ),
          backgroundColor: const Color(0xFF7E0101),
          toolbarHeight: 120,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  //dropdown button mt_type
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      FutureBuilder<List<DropdownMttypeModel>>(
                        future: getMTType(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButtonFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                label: Text(
                                  "ประเภทวัสดุ",
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'กรุณาเลือกประเภทวัสดุ';
                                }
                                return null;
                              },
                              borderRadius: BorderRadius.circular(18.0),
                              value: selectedMttype,
                              dropdownColor: Colors.deepPurple[100],
                              isExpanded: true, //ยาวเต็มหน้าจอ
                              hint: Text(
                                "Select Item",
                                style: TextStyle(
                                  fontFamily: GoogleFonts.mali().fontFamily,
                                ),
                              ),
                              items:
                                  snapshot.data!.map((e) {
                                    return DropdownMenuItem(
                                      value: e.mttypeName.toString(),
                                      child: Text(
                                        e.mttypeName.toString(),
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.mali().fontFamily,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedMttype = value;
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
                  // DropdownFromAPI(), //eq_type
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: mtname,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "ชื่อวัสดุ",
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อวัสดุ';
                      }
                      return null;
                    },
                  ), //user_id
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: mtstock,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "จำนวน",
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกจำนวน';
                      }
                      // Check if input is numeric
                      if (int.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลข';
                      }

                      return null;
                    },
                    keyboardType:
                        TextInputType.number, // Set the keyboard type to number
                  ), //eq_brand
                  const SizedBox(height: 20),
                  // Column(
                  //   children: [
                  //     FutureBuilder<List<DropdownUnitModel>>(
                  //       future: getUnit(),
                  //       builder: (context, snapshot) {
                  //         if (snapshot.hasData) {
                  //           return DropdownButtonFormField(
                  //             decoration: InputDecoration(
                  //               border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(18.0),
                  //               ),
                  //               label: Text(
                  //                 "หน่วยนับ",
                  //                 style: TextStyle(
                  //                   fontFamily: GoogleFonts.mali().fontFamily,
                  //                 ),
                  //               ),
                  //             ),
                  //             validator: (value) {
                  //               if (value == null) {
                  //                 return 'กรุณาเลือกหน่วยนับ';
                  //               }
                  //               return null;
                  //             },
                  //             borderRadius: BorderRadius.circular(18.0),
                  //             value: selectedUnit,
                  //             dropdownColor: Colors.deepPurple[100],
                  //             isExpanded: true, //ยาวเต็มหน้าจอ
                  //             hint: Text(
                  //               "Select Item",
                  //               style: TextStyle(
                  //                 fontFamily: GoogleFonts.mali().fontFamily,
                  //               ),
                  //             ),
                  //             items:
                  //                 snapshot.data!.map((e) {
                  //                   return DropdownMenuItem(
                  //                     value: e.unitName.toString(),
                  //                     child: Text(
                  //                       e.unitName.toString(),
                  //                       style: TextStyle(
                  //                         fontFamily:
                  //                             GoogleFonts.mali().fontFamily,
                  //                       ),
                  //                     ),
                  //                   );
                  //                 }).toList(),
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 selectedUnit = value;
                  //               });
                  //             },
                  //           );
                  //         } else if (snapshot.hasError) {
                  //           return Text("${snapshot.error}");
                  //         } else {
                  //           return const CircularProgressIndicator();
                  //         }
                  //       },
                  //     ),
                  //   ],
                  // ), //eq_model
                  TextFormField(
                    controller: unitid,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "หน่วยนับ",
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกหน่วยนับ';
                      }
                      return null;
                    },
                  ), //user_id
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: unitprice,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "หน่วยละ",
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกราคาต่อหน่วย';
                      }
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลข';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ), //price_unit

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: mtprice,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "จำนวนเงิน",
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกจำนวนเงิน';
                      }
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกตัวเลข';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ), //eq_serial

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: mtdate,
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
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกวันที่ซื้อ';
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
                          mtdate.text = formattedDate;
                        });
                      }
                    },
                  ), //eq_date

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: mtlink,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      label: Text(
                        "ลิงค์ข้อมูลเพิ่มเติม",
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ),
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'กรุณากรอกลิงค์ข้อมูล';
                    //   }
                    //   return null;
                    // },
                  ), //eq_serial

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
                            insertMT();
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
    );
  }
}
