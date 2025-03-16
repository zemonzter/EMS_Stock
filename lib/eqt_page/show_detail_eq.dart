import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/eqt_page/util/update_eq.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowDetail extends StatefulWidget {
  // Change to StatefulWidget
  final String id;
  final String brand;
  final String name;
  final String image;
  final String user;
  final String type;
  final String price;
  final String status;
  final String buydate;
  final String date;
  final String warranty;
  final String token;
  final VoidCallback?
  onRefresh; // Keep the existing onRefresh and make it nullable
  final Future<void> Function()? getRecord;

  const ShowDetail({
    super.key,
    required this.token,
    required this.id,
    required this.brand,
    required this.name,
    required this.image,
    required this.user,
    required this.type,
    required this.price,
    required this.status,
    required this.buydate,
    required this.date,
    required this.warranty,

    this.onRefresh,
    this.getRecord,
  });

  @override
  State<ShowDetail> createState() => _ShowDetailState();
}

class _ShowDetailState extends State<ShowDetail> {
  String userName = '';
  String userRole = '';
  // Add _ShowDetailState
  // The getrecord function doesn't need eqtName anymore.

  @override
  void initState() {
    _getUserData()
        .then((userData) {
          setState(() {
            userName = userData['name'] ?? 'User';
          });
          _fetchUserRole().then((_) {});
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
          });
          _fetchUserRole().then((_) {});
        });
    super.initState();
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(
      Uri.parse('https://api.rmutsv.ac.th/elogin/token/${widget.token}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception(
        'Failed to retrieve user data. Status code: ${response.statusCode}',
      );
    }
  }

  Future<void> _fetchUserRole() async {
    String uri = "${baseUrl}view_user.php";
    try {
      var response = await http.get(Uri.parse(uri));
      final List<dynamic> users = jsonDecode(response.body);

      final user = users.firstWhere(
        (user) => user['user_name'] == userName,
        orElse: () => null,
      );

      if (user != null) {
        setState(() {
          userRole = user['user_role'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_equipment.php";
    try {
      var response = await http.get(Uri.parse(uri));
      jsonDecode(response.body); // Just decode, don't store
      // No setState needed here!  The *caller* of getRecord is responsible for updating the UI.
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteEquipment(BuildContext context) async {
    String uri = "${baseUrl}delete_equipment.php";
    try {
      var response = await http.post(
        Uri.parse(uri),
        body: {"HN_id": widget.id},
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Go back to previous page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบครุภัณฑ์สำเร็จ')));
        widget.onRefresh?.call(); // Call the onRefresh callback if it exists
        // Call getRecord *if it's provided*:
        if (widget.getRecord != null) {
          await widget.getRecord!();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดในการลบครุภัณฑ์')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.brand}  ${widget.name}',
          style: TextStyle(
            fontSize: Responsive.isDesktop(context) ? 26.0 : 22.0,
            fontWeight: FontWeight.bold,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: Responsive.isDesktop(context) ? 1000 : double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.image,
                      width:
                          MediaQuery.of(context).size.width > 1000 ? 600 : 1000,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '${widget.brand}  ${widget.name}',
                  style: TextStyle(
                    fontSize: Responsive.isDesktop(context) ? 26.0 : 22.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ประเภทครุภัณฑ์: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.type,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'เลขครุภัณฑ์: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.id,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ยี่ห้อ: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.brand,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'รุ่น: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.name,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ราคา: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.price,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: ' บาท',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'วันที่ซื้อ: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.buydate,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'วันที่เบิก: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.date,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ระยะเวลาการรับประกัน: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.warranty,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'สถานะ: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.status,
                        style: TextStyle(
                          color:
                              widget.status == 'กำลังใช้งาน' ||
                                      widget.status == 'สำรอง'
                                  ? Colors.green
                                  : widget.status == 'ระหว่างซ่อม' ||
                                      widget.status == 'ชำรุด'
                                  ? Colors.orange
                                  : widget.status == 'รอแทงจำหน่าย'
                                  ? Colors.red
                                  : Colors.black,
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ผู้ถือครอง: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.isDesktop(context) ? 24.0 : 18.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: widget.user,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditEquipmentPage(
                                  onRefresh: () {
                                    // Use the getRecord from ShowDetail, if available.
                                    if (widget.getRecord != null) {
                                      widget.getRecord!();
                                    }
                                  },
                                  hnId: widget.id,
                                ),
                          ),
                        );
                      },
                      child: const Text("แก้ไข"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'ยืนยันการลบประเภทครุภัณฑ์',
                                style: TextStyle(fontSize: 20),
                              ),
                              content: const Text(
                                'คุณแน่ใจหรือไม่ว่าต้องการลบประเภทครุภัณฑ์นี้?',
                                style: TextStyle(fontSize: 12),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    _deleteEquipment(context);
                                  },
                                  child: const Text('ยืนยัน'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('ยกเลิก'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                      ),
                      child: const Text(
                        'ลบ',
                        style: TextStyle(color: Colors.white),
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
