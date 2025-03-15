import 'package:ems_condb/user_page/settings/member/managemember.dart';
import 'package:ems_condb/user_page/settings/member/memberlist.dart';
import 'package:ems_condb/user_page/settings/setting_eq/setting_eq_type.dart';
import 'package:ems_condb/user_page/settings/setting_mainten/edit_mainten_status.dart';
import 'package:ems_condb/user_page/settings/setting_mainten/setting_mainten.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'settings/setting_mt/setting_mt_type.dart';
import 'settings/setting_mt/setting_unit.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        title: Text(
          "Setting",
          style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
        ),
      ),
      body: Padding(
        // Use Padding directly on the body
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: Container(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "จัดการสมาชิก",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                child: Card(
                  child: ListTile(
                    title: Text(
                      "สิทธิ์การใช้งาน",
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageMember(),
                        ),
                      );
                      print('สิทธิ์การใช้งาน');
                    },
                  ),
                ),
              ),
            ),
            Center(
              // ห่อ Card ด้วย Center
              child: SizedBox(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                child: Card(
                  child: ListTile(
                    title: Text(
                      "สมาชิก",
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MemberList(),
                        ),
                      );
                      print('สมาชิก');
                    },
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                margin: const EdgeInsets.only(bottom: 10, top: 10),
                child: Text(
                  "ตั้งค่าครุภัณฑ์",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                child: Card(
                  child: ListTile(
                    title: Text(
                      "จัดการประเภทครุภัณฑ์",
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingEqType(),
                        ),
                      );
                      print('จัดการประเภทครุภัณฑ์');
                    },
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                margin: const EdgeInsets.only(bottom: 10, top: 10),
                child: Text(
                  "ตั้งค่าวัสดุ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                child: Card(
                  child: ListTile(
                    title: Text(
                      "จัดการประเภทวัสดุ",
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingMtType(),
                        ),
                      );
                      print('จัดการประเภทวัสดุ');
                    },
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                child: Card(
                  child: ListTile(
                    title: Text(
                      "จัดการหน่วยนับ",
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingUnit(),
                        ),
                      );
                      print('จัดการหน่วยนับ');
                    },
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                margin: const EdgeInsets.only(bottom: 10, top: 10),
                child: Text(
                  "ตั้งค่าสถานะการซ่อม",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                child: Card(
                  child: ListTile(
                    title: Text(
                      "สถานะการซ่อม",
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const SettingMaintenanceStatus(),
                        ),
                      );
                      print('สถานะการซ่อม');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
