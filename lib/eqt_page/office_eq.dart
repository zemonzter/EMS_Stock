import 'dart:convert';
import 'package:ems_condb/eqt_page/show_detail_eq.dart';
import 'package:ems_condb/eqt_page/util/showproduct.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'util/insert_eq.dart';
import 'package:ems_condb/api_config.dart';

class OfficeEqPage extends StatefulWidget {
  final String eqtName;
  final String token;

  const OfficeEqPage({
    super.key,
    required this.eqtName,
    required this.token,
    required String eqtId,
  });

  @override
  State<OfficeEqPage> createState() => _OfficeEqPageState();
}

class _OfficeEqPageState extends State<OfficeEqPage> {
  List eqdata = [];
  List filteredData = [];
  String searchText = '';
  String userName = '';
  String userRole = ''; // เพิ่ม userRole

  Future<void> getrecord(String eqtName) async {
    String uri = "${baseUrl}view_eq.php";
    try {
      var response = await http.get(Uri.parse(uri));
      final List<dynamic> allData = jsonDecode(response.body);

      List<dynamic> filteredList; // เปลี่ยนเป็น List<dynamic> เพื่อใช้ sort

      if (userRole == 'Admin') {
        filteredList =
            allData.where((data) => data['eq_type'] == eqtName).toList();
      } else {
        filteredList =
            allData
                .where(
                  (data) =>
                      data['eq_type'] == eqtName && data['user_id'] == userName,
                )
                .toList();
      }

      // เรียงลำดับข้อมูลโดยให้ Inactive อยู่ล่างสุด
      filteredList.sort((a, b) {
        if (a['eq_status'] == 'Inactive' && b['eq_status'] != 'Inactive') {
          return 1; // a (Inactive) ควรอยู่หลัง b
        } else if (a['eq_status'] != 'Inactive' &&
            b['eq_status'] == 'Inactive') {
          return -1; // a ควรอยู่ก่อน b (Inactive)
        } else {
          return 0; // ไม่เปลี่ยนแปลงลำดับ
        }
      });

      setState(() {
        eqdata = filteredList;
        filteredData =
            filteredList; // อัปเดต filteredData ด้วยข้อมูลที่เรียงแล้ว
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
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  @override
  void initState() {
    _getUserData()
        .then((userData) {
          setState(() {
            userName = userData['name'] ?? 'User';
          });
          _fetchUserRole().then((_) {
            getrecord(widget.eqtName);
          });
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
          });
          _fetchUserRole().then((_) {
            getrecord(widget.eqtName);
          });
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eqtName,
          style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
        ),
        backgroundColor: const Color(0xFFFFB74B),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                          filteredData =
                              eqdata
                                  .where(
                                    (item) =>
                                        (userRole == 'Admin' ||
                                            item['user_id'] == userName) &&
                                        (item['eq_brand']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['eq_model']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['user_id']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['eq_serial']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['eq_price']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['eq_status']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['eq_warran']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                )),
                                  )
                                  .toList();
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        suffixIcon:
                            searchText.isNotEmpty
                                ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      searchText = '';
                                      filteredData = eqdata;
                                    });
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                                : null,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              if (filteredData.isNotEmpty)
                const Column(
                  children: [
                    Divider(thickness: 3.0, indent: 16.0, endIndent: 16.0),
                    SizedBox(height: 10),
                  ],
                ),
              Expanded(
                child:
                    filteredData.isEmpty
                        ? Center(
                          child: Text(
                            "ไม่มีข้อมูล",
                            style: TextStyle(
                              fontFamily: GoogleFonts.mali().fontFamily,
                            ),
                          ),
                        )
                        : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio:
                                    Responsive.isMobile(context) ? 0.85 : 1,
                              ),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final filteredData = this.filteredData[index];
                            final String eq_id = filteredData['eq_id'] ?? '';
                            final String id = filteredData['eq_serial'] ?? '';
                            final String brand = filteredData['eq_brand'] ?? '';
                            final String name = filteredData['eq_model'] ?? '';
                            final String image =
                                (baseUrl + filteredData["eq_img"] ?? "");
                            final String user = filteredData['user_id'] ?? '';
                            final String type = filteredData['eq_type'] ?? '';
                            final String price = filteredData['eq_price'] ?? '';
                            final String status =
                                filteredData['eq_status'] ?? '';
                            final String date = filteredData['eq_date'] ?? '';
                            final String warranty =
                                filteredData['eq_warran'] ?? '';

                            return SafeArea(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // print('${widget.token}');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => ShowDetail(
                                                      id: id,
                                                      name: name,
                                                      image: image,
                                                      brand: brand,
                                                      user: user,
                                                      type: type,
                                                      price: price,
                                                      date: date,
                                                      warranty: warranty,
                                                      status: status,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Showproduct(
                                            status: status,
                                            brand: brand,
                                            blockName: name,
                                            blockImage: image,
                                            blockHN: id,
                                            user: user,
                                            eqId: eq_id,
                                            onRefresh: () {
                                              getrecord(widget.eqtName);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
