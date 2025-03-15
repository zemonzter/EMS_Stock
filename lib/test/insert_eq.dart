import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../eqt_page/util/textformfield.dart';

const String url = "http://10.0.2.2/test_condb/";

class InsertEq extends StatefulWidget {
  const InsertEq({super.key});

  @override
  State<InsertEq> createState() => _InsertEqState();
}

class _InsertEqState extends State<InsertEq> {
  // TextEditingController eqtname = TextEditingController();
  TextEditingController user_id = TextEditingController();
  TextEditingController eq_model = TextEditingController();
  TextEditingController eq_brand = TextEditingController();
  TextEditingController eq_serial = TextEditingController();
  TextEditingController eq_status = TextEditingController();
  TextEditingController eq_price = TextEditingController();
  TextEditingController eq_date = TextEditingController();
  TextEditingController eq_warran = TextEditingController();

  File? imagepath;
  String? imagename;
  String? imagedata;

  ImagePicker imagePicker = ImagePicker();

  Future<void> insertEq() async {
    if (
    // eqtname.text != '' &&
    user_id.text != '' &&
        eq_model.text != '' &&
        eq_brand.text != '' &&
        eq_serial.text != '' &&
        eq_status.text != '' &&
        eq_price.text != '' &&
        eq_date.text != '' &&
        eq_warran.text != '') {
      try {
        String uri = "${url}insert_eq.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {
            // "eqtname": selectedValue.toString(),
            "user_id": user_id.text,
            "eq_model": eq_model.text,
            "eq_brand": eq_brand.text,
            "eq_serial": eq_serial.text,
            "eq_status": eq_status.text,
            "eq_price": eq_price.text,
            "eq_date": eq_date.text,
            "eq_warran": eq_warran.text,
            "data":
                imagedata?.isNotEmpty == true
                    ? imagedata
                    : "", // Handle potential null for imagedata
            "name": imagename ?? "", // Handle potential null for imagename
          },
        );

        var response = jsonDecode(res.body);
        if (response['success'] == 'true') {
          print("Record inserted successfully");
        } else {
          print("Error inserting record");
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("please fill all the details");
    }
  }

  // Future<List<DropdownModel>> getPost() async {
  //   try {
  //     final response = await http.get(Uri.parse("${url}view_eqt.php"));
  //     final body = json.decode(response.body) as List;

  //     if (response.statusCode == 200) {
  //       return body.map((e) {
  //         final map = e as Map<String, dynamic>;
  //         return DropdownModel(eqtId: map["eqt_id"], eqtName: map["eqt_name"]);
  //       }).toList();
  //     }
  //   } on SocketException {
  //     throw Exception('No Internet connection');
  //   }
  //   throw Exception("Fetch Data Error");
  // }

  // var selectedValue;

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
          title: const Text(
            "เพิ่มครุภัณฑ์",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF7E0101),
          toolbarHeight: 120,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // Textformfield(fieldname: "เลขครุภัณฑ์"), //eq_id

                //dropdown button eq_type
                // Column(
                //   children: [
                //     const SizedBox(height: 20),
                //     FutureBuilder<List<DropdownModel>>(
                //         future: getPost(),
                //         builder: (context, snapshot) {
                //           if (snapshot.hasData) {
                //             return DropdownButtonFormField(
                //               decoration: InputDecoration(
                //                 border: OutlineInputBorder(
                //                   borderRadius: BorderRadius.circular(18.0),
                //                 ),
                //                 label: const Text("ประเภทครุภัณฑ์"),
                //               ),
                //               borderRadius: BorderRadius.circular(18.0),
                //               value: selectedValue,
                //               dropdownColor: Colors.deepPurple[100],
                //               isExpanded: true, //ยาวเต็มหน้าจอ
                //               hint: const Text("Select Item"),
                //               items: snapshot.data!.map((e) {
                //                 return DropdownMenuItem(
                //                     value: e.eqtName.toString(),
                //                     child: Text(e.eqtName.toString()));
                //               }).toList(),
                //               onChanged: (value) {
                //                 setState(() {
                //                   selectedValue = value;
                //                 });
                //               },
                //             );
                //           } else if (snapshot.hasError) {
                //             return Text("${snapshot.error}");
                //           } else {
                //             return const CircularProgressIndicator();
                //           }
                //         })
                //   ],
                // ),
                // DropdownFromAPI(), //eq_type
                Textformfield(
                  controller: user_id.text,
                  fieldname: "ผู้ถือครอง",
                ), //user_id
                Textformfield(
                  controller: eq_model.text,
                  fieldname: "รุ่นครุภัณฑ์",
                ), //eq_model
                Textformfield(
                  controller: eq_brand.text,
                  fieldname: "ยี่ห้อครุภัณฑ์",
                ), //eq_brand
                Textformfield(
                  controller: eq_serial.text,
                  fieldname: "หมายเลขซีเรียล",
                ), //eq_serial
                Textformfield(
                  controller: eq_status.text,
                  fieldname: "สถานะ",
                ), //eq_status
                Textformfield(
                  controller: eq_price.text,
                  fieldname: "ราคา",
                ), //eq_price
                Textformfield(
                  controller: eq_date.text,
                  fieldname: "วันที่ซื้อ",
                ), //eq_date
                Textformfield(
                  controller: eq_warran.text,
                  fieldname: "ระยะเวลาประกัน",
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
                  child: const Text('Choose image'),
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
                          Navigator.pop(context);
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
        ),
      ),
    );
  }
}
