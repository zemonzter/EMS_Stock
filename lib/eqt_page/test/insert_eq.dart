import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/eqt_page/util/models/dropdown_model.dart';
import 'package:ems_condb/eqt_page/util/models/dropdown_status.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({super.key});

  @override
  State<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _hnidController = TextEditingController();
  final _eqtnameController = TextEditingController();
  final _useridController = TextEditingController();
  final _eqnameController = TextEditingController();
  final _eqmodelController = TextEditingController();
  final _eqbrandController = TextEditingController();
  final _eqserialController = TextEditingController();
  final _eqstatusController = TextEditingController();
  final _eqpriceController = TextEditingController();
  final _eqwarranController = TextEditingController();
  final _quantityController = TextEditingController(
    text: '1',
  ); // Initialize with 1

  DateTime? _eqbuydate;
  DateTime? _eqdate;

  // Image variable
  File? imagepath;
  String? imagename;
  String? imagedata;
  ImagePicker imagePicker = ImagePicker();
  String? selectedStatus;
  var selectedType;

  // Function to pick an image
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

  // Function to handle date selection
  Future<void> _selectDate(BuildContext context, bool isBuyDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBuyDate) {
          _eqbuydate = picked;
        } else {
          _eqdate = picked;
        }
      });
    }
  }

  // Function to handle form submission (NOW HANDLES MULTIPLE INSERTS)
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      int quantity = int.tryParse(_quantityController.text) ?? 1;
      if (quantity <= 0) {
        quantity = 1;
      }

      String hnId = _hnidController.text; // เก็บค่า hn_id เดิม

      Map<String, String> body = {
        'hn_id': hnId,
        'eqtname': selectedType.toString(),
        'userid': _useridController.text,
        'eqname': _eqnameController.text,
        'eqmodel': _eqmodelController.text,
        'eqbrand': _eqbrandController.text,
        'eqserial': _eqserialController.text,
        'eqstatus': selectedStatus.toString(),
        'eqprice': _eqpriceController.text,
        'eqwarran': _eqwarranController.text,
        'eqbuydate':
            _eqbuydate != null
                ? DateFormat('yyyy-MM-dd').format(_eqbuydate!)
                : '',
        'eqdate':
            _eqdate != null ? DateFormat('yyyy-MM-dd').format(_eqdate!) : '',
        'quantity': quantity.toString(), // ส่ง quantity ไปยัง server
        "data": imagedata?.isNotEmpty == true ? imagedata ?? "" : "",
        "name": imagename ?? "",
      };
      // if (_base64Image != null) {
      //   body['data'] = _base64Image!;
      //   body['name'] = _image!.path.split('/').last;
      //   print("Base64 Image: $_base64Image"); // เพิ่มการ debug
      //   print("Image Path: ${_image!.path}");
      // }

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/insert_eq_new.php'),
          body: body,
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['success'] == 'true') {
            if (jsonResponse.containsKey('generated_hn_id')) {
              // แสดง hn_id ที่ถูกสร้างใหม่
              _showDialog(
                context,
                "สำเร็จ",
                "ครุภัณฑ์ $quantity รายการได้รับการบันทึก! HN_id ใหม่: ${jsonResponse['generated_hn_id']}",
              );
            } else {
              _showDialog(
                context,
                "สำเร็จ",
                "ครุภัณฑ์ $quantity รายการได้รับการบันทึก!",
              );
            }
            _clearForm();
          } else {
            _showDialog(context, "เกิดข้อผิดพลาด", jsonResponse['error']);
          }
        } else {
          _showDialog(context, "Error", "Server error: ${response.statusCode}");
        }
      } catch (e) {
        _showDialog(context, "Error", "Exception: $e");
      }
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  // Clear form
  void _clearForm() {
    _formKey.currentState!.reset();
    _hnidController.clear();
    _eqtnameController.clear();
    _useridController.clear();
    _eqnameController.clear();
    _eqmodelController.clear();
    _eqbrandController.clear();
    _eqserialController.clear();
    _eqstatusController.clear();
    _eqpriceController.clear();
    _eqwarranController.clear();
    _quantityController.text = '1'; // Reset quantity to 1

    setState(() {
      _eqbuydate = null;
      _eqdate = null;
      imagepath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เพิ่มครุภัณฑ์',
          style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
        ),
      ),
      body: SizedBox(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // eq_type
                // TextFormField(
                //   controller: _eqtnameController,
                //   decoration: InputDecoration(
                //     labelText: 'ประเภทครุภัณฑ์',
                //     labelStyle: TextStyle(
                //       fontFamily: Fonts.Fontnormal.fontFamily,
                //     ),
                //   ),
                //   validator:
                //       (value) =>
                //           value!.isEmpty ? 'Please enter equipment type' : null,
                // ),
                Column(
                  children: [
                    const SizedBox(height: 20),
                    FutureBuilder<List<DropdownModel>>(
                      future: getPost(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DropdownButtonFormField(
                            decoration: InputDecoration(
                              label: Text(
                                "ประเภทครุภัณฑ์",
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
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
                              "เลือกประเภทครุภัณฑ์",
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
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

                // eq_serial (HN_id part)
                TextFormField(
                  controller: _hnidController,
                  decoration: InputDecoration(
                    labelText: 'เลขครุภัณฑ์ (XXX)',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'กรุณากรอกข้อมูลเลขครุภัณฑ์' : null,
                ),
                // user_name
                TextFormField(
                  controller: _useridController,
                  decoration: InputDecoration(
                    labelText: 'ผู้ถือครอง',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'กรุณากรอกข้อมูลผู้ถือครอง' : null,
                ),
                // eq_name
                TextFormField(
                  controller: _eqnameController,
                  decoration: InputDecoration(
                    labelText: 'ชื่อครุภัณฑ์',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'กรุณากรอกข้อมูลชื่อครุภัณฑ์' : null,
                ),
                // eq_brand
                TextFormField(
                  controller: _eqbrandController,
                  decoration: InputDecoration(
                    labelText: 'ยี่ห้อ',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'กรุณากรอกข้อมูลยี่ห้อ' : null,
                ),
                // eq_model
                TextFormField(
                  controller: _eqmodelController,
                  decoration: InputDecoration(
                    labelText: 'รุ่น',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'กรุณากรอกข้อมูลรุ่น' : null,
                ),

                // eq_status
                // TextFormField(
                //   controller: _eqstatusController,
                //   decoration: InputDecoration(
                //     labelText: 'สถานะ',
                //     labelStyle: TextStyle(
                //       fontFamily: Fonts.Fontnormal.fontFamily,
                //     ),
                //   ),
                //   validator:
                //       (value) => value!.isEmpty ? 'กรุณากรอกข้อมูลสถานะ' : null,
                // ),
                Column(
                  children: [
                    FutureBuilder<List<DropdownStatus>>(
                      future: getStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DropdownButtonFormField(
                            decoration: InputDecoration(
                              // border: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(18.0),
                              // ),
                              label: Text(
                                "สถานะ",
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
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
                              "เลือกสถานะ",
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                            items:
                                snapshot.data!.map((e) {
                                  return DropdownMenuItem(
                                    value: e.status,
                                    child: Text(
                                      e.status,
                                      style: TextStyle(
                                        fontFamily: Fonts.Fontnormal.fontFamily,
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
                // eq_price
                TextFormField(
                  controller: _eqpriceController,
                  decoration: InputDecoration(
                    labelText: 'ราคา',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณากรอกข้อมูลราคา';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณากรอกข้อมูลราคาให้ถูกต้อง';
                    }
                    return null;
                  },
                ),
                // eq_buydate
                ListTile(
                  title: Text(
                    'วันที่ซื้อ: ${_eqbuydate != null ? DateFormat('yyyy-MM-dd').format(_eqbuydate!) : 'เลือกวันที่'}',
                    style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                ),
                // eq_date
                ListTile(
                  title: Text(
                    'วันที่เบิก: ${_eqdate != null ? DateFormat('yyyy-MM-dd').format(_eqdate!) : 'เลือกวันที่'}',
                    style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                ),

                // eq_warran
                TextFormField(
                  controller: _eqwarranController,
                  decoration: InputDecoration(
                    labelText: 'ระยะเวลาประกัน',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? 'กรุณากรอกข้อมูลระยะเวลาประกัน'
                              : null,
                ),
                // Quantity
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'จำนวน',
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณากรอกจำนวน';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'กรุณากรอกจำนวนให้ถูกต้อง';
                    }
                    return null;
                  },
                ),
                // eq_img
                Column(
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () => getImage(),
                        child: Text(
                          'เลือกรูปภาพ',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    if (imagepath != null) ...[
                      SizedBox(height: 10),
                      Stack(
                        // เพิ่ม Stack เพื่อวางปุ่มลบบนรูปภาพ
                        alignment: Alignment.topRight, // จัดปุ่มลบไว้มุมบนขวา
                        children: [
                          Image.file(imagepath!, height: 150),
                          IconButton(
                            // ปุ่มลบรูปภาพ
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                imagepath = null; // ลบรูปภาพ
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          'เพิ่มครุภัณฑ์',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _hnidController.dispose();
    _eqtnameController.dispose();
    _useridController.dispose();
    _eqnameController.dispose();
    _eqmodelController.dispose();
    _eqbrandController.dispose();
    _eqserialController.dispose();
    _eqstatusController.dispose();
    _eqpriceController.dispose();
    _eqwarranController.dispose();
    _quantityController.dispose(); // Dispose of the quantity controller
    super.dispose();
  }
}
