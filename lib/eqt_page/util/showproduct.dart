import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/eqt_page/util/update_eq.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Showproduct extends StatelessWidget {
  final String blockHN;
  final String brand;
  final String blockName;
  final String user;
  final String status;
  final String blockImage;
  final String eqId;
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
    this.onRefresh,
  });

  Future<void> _deleteEquipment(BuildContext context) async {
    final url = Uri.parse('${baseUrl}delete_eq.php');
    try {
      final response = await http.post(url, body: {'eq_id': eqId});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['success'] == 'true') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ลบรายการสำเร็จ',
                style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
              ),
              backgroundColor: Colors.green,
            ),
          );
          onRefresh?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'เกิดข้อผิดพลาด: ${data['message'] ?? 'ไม่สามารถลบรายการได้'}',
                style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
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
              style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
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
            style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
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
            style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
          ),
          content: Text(
            'คุณต้องการลบรายการนี้ใช่หรือไม่?',
            style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ยกเลิก',
                style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'ลบ',
                style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
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
    double fontSize = 14;
    double statusFontSize = 12;
    double userFontSize = 14;
    double paddingValue = 18.0;
    double sizedBoxHeight = 20;
    double top = 15;
    double right = 15;

    if (Responsive.isTablet(context)) {
      containerWidth = 190;
      containerHeight = 220;
      avatarRadius = 70;
      fontSize = 16;
      statusFontSize = 16;
      userFontSize = 18;
      paddingValue = 24.0;
      sizedBoxHeight = 30;
      top = 12;
      right = 12;
    } else if (Responsive.isDesktop(context)) {
      containerWidth = 210;
      containerHeight = 240;
      avatarRadius = 80;
      fontSize = 18;
      statusFontSize = 18;
      userFontSize = 20;
      paddingValue = 10.0;
      sizedBoxHeight = 10;
      top = 8;
      right = 8;
    }

    return GestureDetector(
      onTap: onTap,
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
            Positioned(
              top: top,
              right: right,
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  // Make onSelected async
                  if (value == 'edit') {
                    // Navigate to UpdateEquipment and await the result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => UpdateEquipment(
                              eqName: blockName,
                              brand: brand,
                              // token: token,
                              //     eqId, // Assuming you want to pass eqId as token
                              // eqData: {
                              //   'eq_id': eqId, // Pass all necessary data
                              //   'eq_name': blockName,
                              //   'eq_brand': brand,
                              //   'eq_img': blockImage,
                              //   'eq_hn': blockHN,
                              //   'user': user,
                              //   'status': status,
                              //   // ... other fields ...
                              // },
                            ),
                      ),
                    );
                    // If the update was successful (we get 'true' back), refresh
                    if (result == true) {
                      onRefresh?.call(); // Use the null-check operator
                    }
                  } else if (value == 'delete') {
                    _confirmDelete(context);
                  }
                },
                itemBuilder: (context) {
                  return ['edit', 'delete'].map((choice) {
                    return PopupMenuItem(
                      value: choice,
                      child: Text(
                        choice == 'edit' ? 'แก้ไข' : 'ลบ',
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
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
                      backgroundImage: NetworkImage(blockImage),
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
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                status == 'Inactive'
                                    ? Colors.red
                                    : Colors.green,
                            fontSize: statusFontSize,
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'HN: $blockHN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontSize,
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '$brand $blockName',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontSize,
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          user,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: userFontSize,
                            fontFamily: GoogleFonts.mali().fontFamily,
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
