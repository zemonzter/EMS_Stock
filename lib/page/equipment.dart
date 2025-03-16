import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/eqt_page/office_eq.dart';
import 'package:ems_condb/eqt_page/test/view_equipment.dart';
import 'package:ems_condb/eqt_page/util/insert_eq.dart';
import 'package:ems_condb/user_page/settings/setting_eq/insert_eq_type.dart';
// import 'package:ems_condb/util/block.dart';
import 'package:ems_condb/util/eq_block.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EquipmentPage extends StatefulWidget {
  final String? token;
  const EquipmentPage({super.key, required this.token});

  @override
  State<EquipmentPage> createState() => _HomePageState();
}

class _HomePageState extends State<EquipmentPage> {
  List eqtdata = [];
  List record = [];
  bool _isLoading = true;
  String userName = '';
  String userRole = '';

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_eqt.php";
    try {
      var response = await http.get(Uri.parse(uri));

      setState(() {
        eqtdata = jsonDecode(response.body);
        record = jsonDecode(response.body);
      });
    } catch (e) {
      print(e);
    }
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
          _isLoading = false; // Set loading to false
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        _isLoading = false; // Set loading to false on error
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getrecord();
    super.initState();
    _getUserData()
        .then((userData) {
          setState(() {
            userName = userData['name'] ?? 'User';
          });
          _fetchUserRole(); // Just call it
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
            _isLoading = false; // Set loading to false on error
          });
          _fetchUserRole(); // Call it here too
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ประเภทครุภัณฑ์",
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (userRole == 'Admin')
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InsertEq()),
                );
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: Responsive.isMobile(context) ? double.infinity : 700,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: record.length,
            itemBuilder: (context, index) {
              final String id = eqtdata[index]['eqt_id'] ?? '';
              final String name = eqtdata[index]['eqt_name'] ?? '';
              final String image = (baseUrl + record[index]["eqt_img"] ?? "");
              //final String image = (record[index]["http://10.0.2.2/test_condb/"] ?? "") + "/test_condb";

              return SafeArea(
                // child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.all(16.0),
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EQBlockDetail(
                            blockName: name,
                            blockImage: image,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OfficeEqPage(
                                        eqtId: id,
                                        eqtName: name,
                                        token: widget.token ?? '',
                                      ),
                                ),
                                // MaterialPageRoute(
                                //   builder: (context) => EquipmentList(),
                                // ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                    // ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
