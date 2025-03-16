import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/eqt_page/util/update_eq.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Showproduct extends StatefulWidget {
  final String blockHN;
  final String name;
  final String brand;
  final String blockName;
  final String user;
  final String status;
  final String blockImage;
  final String eqId;
  final String buyDate;
  final String date;
  final String price;
  final String warranty;
  final String token;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const Showproduct({
    super.key,
    this.onTap,
    required this.blockName,
    required this.blockImage,
    required this.blockHN,
    required this.user,
    required this.status,
    required this.brand,
    required this.eqId,
    required this.buyDate,
    required this.date,
    required this.price,
    required this.warranty,
    required this.token,
    this.onRefresh,
    required this.name,
  });

  @override
  State<Showproduct> createState() => _ShowproductState();
}

class _ShowproductState extends State<Showproduct> {
  String userName = '';
  String userRole = '';

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

  Future<void> _deleteEquipment(BuildContext context) async {
    final url = Uri.parse('${baseUrl}delete_equipment.php');
    try {
      final response = await http.post(url, body: {'HN_id': widget.eqId});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ลบรายการสำเร็จ',
                style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
              backgroundColor: Colors.green,
            ),
          );
          widget.onRefresh?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'เกิดข้อผิดพลาด: ${data['message'] ?? 'ไม่สามารถลบรายการได้'}',
                style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${response.statusCode}',
              style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'เกิดข้อผิดพลาด: $e',
            style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'ยืนยันการลบ',
            style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
          ),
          content: Text(
            'คุณต้องการลบรายการนี้ใช่หรือไม่?',
            style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ยกเลิก',
                style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'ลบ',
                style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteEquipment(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = 165;
    double containerHeight = 175;
    double avatarRadius = 50;
    double hnfontSize = 14;
    double fontSize = 12;
    double statusFontSize = 10;
    double userFontSize = 14;
    double paddingValue = 18.0;
    double sizedBoxHeight = 20;
    double top = 15;
    double right = 15;

    if (Responsive.isTablet(context)) {
      containerWidth = 190;
      containerHeight = 220;
      avatarRadius = 70;
      hnfontSize = 14;
      fontSize = 12;
      statusFontSize = 12;
      userFontSize = 16;
      paddingValue = 24.0;
      sizedBoxHeight = 30;
      top = 12;
      right = 12;
    } else if (Responsive.isDesktop(context)) {
      containerWidth = 210;
      containerHeight = 240;
      avatarRadius = 80;
      hnfontSize = 16;
      fontSize = 14;
      statusFontSize = 14;
      userFontSize = 18;
      paddingValue = 10.0;
      sizedBoxHeight = 10;
      top = 8;
      right = 8;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                  color: Color.fromRGBO(240, 240, 240, 1),
                ),
              ),
            ),
            if (userRole == 'Admin')
              Positioned(
                top: top,
                right: right,
                child: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    // Make onSelected async
                    if (value == 'edit') {
                      print(widget.blockHN);
                      // Navigate to UpdateEquipment and await the result
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditEquipmentPage(
                                // equipmentData: {
                                //   'eq_model': blockName,
                                //   'eq_brand': brand,
                                //   'eq_img': blockImage,
                                //   'HN_id': eqId,
                                //   'user_name': user,
                                //   'eq_status': status,
                                //   'eq_name': name,
                                //   'eq_buydate': buyDate,
                                //   'eq_date': date,
                                // },
                                hnId: widget.blockHN,
                                onRefresh: () {
                                  widget.onRefresh?.call();
                                },
                              ),
                        ),
                      );
                      // If the update was successful (we get 'true' back), refresh
                      if (result == true) {
                        widget.onRefresh?.call(); // Use the null-check operator
                      }
                    } else if (value == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  // onSelected: (value) async {
                  //   // Make onSelected async
                  //   if (value == 'edit') {
                  //     // Navigate to UpdateEquipment and await the result
                  //     final result = await Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder:
                  //             (context) => UpdateEquipment(
                  //               eqName: blockName,
                  //               brand: brand,
                  //               // token: token,
                  //               //     eqId, // Assuming you want to pass eqId as token
                  //               // eqData: {
                  //               //   'eq_id': eqId, // Pass all necessary data
                  //               //   'eq_name': blockName,
                  //               //   'eq_brand': brand,
                  //               //   'eq_img': blockImage,
                  //               //   'eq_hn': blockHN,
                  //               //   'user': user,
                  //               //   'status': status,
                  //               //   // ... other fields ...
                  //               // },
                  //             ),
                  //       ),
                  //     );
                  //     // If the update was successful (we get 'true' back), refresh
                  //     if (result == true) {
                  //       onRefresh?.call(); // Use the null-check operator
                  //     }
                  //   } else if (value == 'delete') {
                  //     _confirmDelete(context);
                  //   }
                  // },
                  itemBuilder: (context) {
                    return ['edit', 'delete'].map((choice) {
                      return PopupMenuItem(
                        value: choice,
                        child: Text(
                          choice == 'edit' ? 'แก้ไข' : 'ลบ',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: sizedBoxHeight),
                  Center(
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: NetworkImage(widget.blockImage),
                    ),
                  ),
                  Container(
                    width: containerWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          offset: Offset(0, 4),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                widget.status == 'กำลังใช้งาน' ||
                                        widget.status == 'สำรอง'
                                    ? Colors
                                        .green // กำลังใช้งาน หรือ สำรอง -> สีเขียว
                                    : widget.status == 'ระหว่างซ่อม' ||
                                        widget.status == 'ชำรุด'
                                    ? Colors
                                        .orange // ระหว่างซ่อม หรือ ชำรุด -> สีส้ม
                                    : widget.status == 'รอแทงจำหน่าย'
                                    ? Colors
                                        .red // รอแทงจำหน่าย -> สีแดง
                                    : Colors.black,
                            fontSize: statusFontSize,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'HN: ${widget.blockHN}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: hnfontSize,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${widget.name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontSize,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${widget.brand} ${widget.blockName}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontSize,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          widget.user,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: userFontSize,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
