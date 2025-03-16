import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

const String api = "https://api.rmutsv.ac.th/elogin/token/";

class MaintenanceForm extends StatefulWidget {
  final String? token;
  const MaintenanceForm({super.key, required this.token});

  @override
  State<MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<MaintenanceForm> {
  TextEditingController eqid = TextEditingController();
  TextEditingController eqname = TextEditingController();
  TextEditingController maintendate = TextEditingController();
  TextEditingController maintendetail = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? imagepath;
  String? imagename;
  String? imagedata;
  List _eqList = []; // Store fetched equipment list

  ImagePicker imagePicker = ImagePicker();

  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(Uri.parse(api + widget.token!));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception(
        'Failed to retrieve user data. Status code: ${response.statusCode}',
      );
    }
  }

  // Fetch the equipment list from the API
  Future<void> _fetchEqList() async {
    String uri = "${baseUrl}view_equipment.php";
    try {
      var response = await http.get(Uri.parse(uri));
      if (response.statusCode == 200) {
        setState(() {
          _eqList = jsonDecode(response.body);
        });
      } else {
        // Consider showing a SnackBar or other UI indication of the error.
        throw Exception(
          'Failed to retrieve equipment list. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Handle network errors, etc.
      print("Error fetching equipment list: $e");
      // Consider showing a SnackBar here, or setting an error state to display a message.
      rethrow; // Re-throw to allow FutureBuilder to handle error state.
    }
  }

  // Filter the equipment list based on search text.  Returns the filtered list.
  List _filterEqList(String searchText) {
    if (searchText.isEmpty) {
      return []; // คืนค่ารายการว่างเมื่อข้อความค้นหาว่างเปล่า
    }
    final lowerSearchText =
        searchText.toLowerCase(); // แปลงข้อความค้นหาเป็นตัวพิมพ์เล็ก
    return _eqList
        .where(
          (element) => element['HN_id']
              .toString()
              .toLowerCase() // แปลงค่าใน 'HN_id' เป็นตัวพิมพ์เล็ก
              .contains(lowerSearchText),
        )
        .toList();
  }

  Future<void> _getEqName(String eqId) async {
    // No need for API call here, we'll use the already fetched _eqList

    // Find the equipment with the matching eqid
    var eqData = _eqList.firstWhere(
      (element) => element['HN_id'] == eqId,
      orElse: () => null, // Return null if no match is found
    );

    if (eqData != null) {
      // Use addPostFrameCallback here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            eqname.text =
                "${eqData['eq_name']} ${eqData['eq_brand']} ${eqData['eq_model']}";
          });
        }
      });
    } else {
      // Use addPostFrameCallback here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if mounted
          setState(() {
            eqname.text = ''; // Clear eqname if no match is found
          });
        }
      });
    }
  }

  Future<void> maintenForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String uri = "${baseUrl}mainten_form.php";

        final userData = await _getUserData();

        var res = await http.post(
          Uri.parse(uri),
          body: {
            "eqid": eqid.text,
            "eqname": eqname.text,
            "maintendate": maintendate.text,
            "maintendetail": maintendetail.text,
            "usermainten": "${userData['name']}",
            "data": imagedata ?? "",
            "name": imagename ?? "",
          },
        );

        var response = jsonDecode(res.body);
        if (response['success'] == 'true') {
          print("Record inserted successfully");

          //Use addPostFrameCallback here
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Check if mounted.
              setState(() {
                eqid.clear();
                eqname.clear();
                maintendate.clear();
                maintendetail.clear();
                imagepath = null;
                imagename = null;
                imagedata = null;
              });
            }
          });

          // Show success dialog and navigate back.  CRUCIAL CHANGE HERE:
          bool? shouldRefresh = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'ส่งคำขอแจ้งซ่อมสำเร็จ',
                  style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                ),
                content: Text(
                  'รอการดำเนินงานจากเจ้าหน้าที่',
                  style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Return true
                    },
                    child: Text(
                      'ตกลง',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                  ),
                ],
              );
            },
          );

          // Only navigate back if the dialog was dismissed with "OK".
          if (shouldRefresh == true) {
            Navigator.of(
              context,
            ).pop(true); // Pop MaintenanceForm, returning true
          }
        } else {
          print("Error inserting record");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูล'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // No changes needed here. The dialog is already handled correctly.
        bool? shouldRefresh = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'ส่งคำขอแจ้งซ่อมสำเร็จ',
                style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
              content: Text(
                'รอการดำเนินงานจากเจ้าหน้าที่',
                style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                  child: Text(
                    'ตกลง',
                    style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                  ),
                ),
              ],
            );
          },
        );

        if (shouldRefresh == true) {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      print("please fill all the details");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณากรอกข้อมูลให้ครบถ้วน',
            style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
          ),
          backgroundColor: Colors.orange[300],
        ),
      );
    }
  }

  Future<void> getImage() async {
    var getimage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (getimage == null) return;

    setState(() {
      imagepath = File(getimage.path);
      imagename = getimage.path.split('/').last;
      imagedata = base64Encode(imagepath!.readAsBytesSync());
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEqList(); // Fetch the list when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "แจ้งซ่อม",
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        toolbarHeight: 120,
        leading: IconButton(
          // Add a back button
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Just pop the current screen.
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Autocomplete<String>(
                      // Specify the type as String
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return _filterEqList(
                          textEditingValue.text,
                        ).map((item) => item['HN_id'].toString());
                      },
                      onSelected: (String selection) {
                        // Use addPostFrameCallback here.  VERY IMPORTANT!
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            // Check if mounted
                            setState(() {
                              eqid.text = selection;
                            });
                            _getEqName(selection);
                          }
                        });
                      },
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        // Use addPostFrameCallback to set the initial text.
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            fieldTextEditingController.text = eqid.text;
                          }
                        });

                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            labelText: "เลขครุภัณฑ์",
                            labelStyle: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {},
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'กรุณากรอกข้อมูลเลขครุภัณฑ์';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: eqname,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        labelText: "ชื่อครุภัณฑ์",
                        labelStyle: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: maintendate,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        labelText: "วันที่แจ้งซ่อม",
                        labelStyle: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
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
                            maintendate.text = formattedDate;
                          });
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'กรุณาเลือกวันที่แจ้งซ่อม';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: maintendetail,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        labelText: "อาการ/ปัญหา",
                        labelStyle: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'กรุณากรอกข้อมูลอาการ/ปัญหา';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasData) {
                          final userData = snapshot.data!;

                          final expectedKeys = ['name'];
                          for (var key in expectedKeys) {
                            if (!userData.containsKey(key)) {
                              print('Warning: Key "$key" missing in user data');
                            }
                          }

                          return TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              labelText: 'ผู้แจ้งซ่อม: ${userData['name']}',
                              labelStyle: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    imagepath != null
                        ? Image.file(imagepath!)
                        : Image.asset('assets/images/default.jpg'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        getImage();
                        // print($image_path_for_db)
                      },
                      child: Text(
                        'เลือกรูปภาพ',
                        style: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
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
                              maintenForm(); // Call the submission function.
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
