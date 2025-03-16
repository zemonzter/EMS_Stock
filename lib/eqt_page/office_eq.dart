import 'dart:convert';
import 'package:ems_condb/eqt_page/show_detail_eq.dart';
import 'package:ems_condb/eqt_page/test/insert_eq.dart';
import 'package:ems_condb/eqt_page/util/showproduct.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  String userRole = '';
  bool isTableView = false;

  Future<void> getrecord(String eqtName) async {
    String uri = "${baseUrl}view_equipment.php";
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
                      data['eq_type'] == eqtName &&
                      data['user_name'] == userName,
                )
                .toList();
      }

      // เรียงลำดับข้อมูลโดยให้ Inactive อยู่ล่างสุด
      filteredList.sort((a, b) {
        if (a['eq_status'] == 'รอแทงจำหน่าย' &&
            b['eq_status'] != 'รอแทงจำหน่าย') {
          return 1; // a (Inactive) ควรอยู่หลัง b
        } else if (a['eq_status'] != 'รอแทงจำหน่าย' &&
            b['eq_status'] == 'รอแทงจำหน่าย') {
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
          style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
        ),
        backgroundColor: const Color(0xFFFFB74B),
        actions: [
          if (userRole == 'Admin')
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  // MaterialPageRoute(builder: (context) => const InsertEq()),
                  MaterialPageRoute(
                    builder: (context) => const AddEquipmentPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: Responsive.isMobile(context) ? double.infinity : 1000,
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
                                            item['user_name'] == userName) &&
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
                                            item['user_name']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['HN_id']
                                                .toLowerCase()
                                                .contains(
                                                  searchText.toLowerCase(),
                                                ) ||
                                            item['eq_name']
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
              if (filteredData
                  .isNotEmpty) // เพิ่มเงื่อนไขเพื่อแสดงปุ่มเมื่อมีข้อมูล
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ), // เพิ่ม padding ให้ปุ่ม
                  child: Align(
                    alignment: Alignment.centerRight, // จัดปุ่มไปทางขวา
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isTableView = !isTableView;
                        });
                      },
                      icon: Icon(
                        isTableView ? Icons.view_module : Icons.table_chart,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child:
                    filteredData.isEmpty
                        ? Center(
                          child: Text(
                            "ไม่มีข้อมูล",
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        )
                        : isTableView
                        ? _buildTableView()
                        : _buildGridView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
        childAspectRatio: Responsive.isMobile(context) ? 0.85 : 0.75,
      ),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final filteredData = this.filteredData[index];
        final String pricef =
            filteredData['eq_price'] ?? '0.00'; // เก็บ price เป็น String
        final double parsedPrice =
            double.tryParse(pricef) ?? 0.00; // แปลงเป็น double
        final formattedPrice = NumberFormat("#,###.00").format(parsedPrice);
        final String eq_id = filteredData['HN_id'] ?? '';
        final String id = filteredData['HN_id'] ?? '';
        final String eq_name = filteredData['eq_name'] ?? '';
        final String brand = filteredData['eq_brand'] ?? '';
        final String name = filteredData['eq_model'] ?? '';
        final String image = (baseUrl + filteredData["eq_img"] ?? "");
        final String user = filteredData['user_name'] ?? '';
        final String type = filteredData['eq_type'] ?? '';
        final String price = formattedPrice;
        final String status = filteredData['eq_status'] ?? '';
        final String buydate = filteredData['eq_buydate'] ?? '';
        final String date = filteredData['eq_date'] ?? '';
        final String warranty = filteredData['eq_warran'] ?? '';

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  buydate: buydate,
                                  onRefresh: () {
                                    getrecord(widget.eqtName);
                                  },
                                  token: widget.token,
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
                        name: eq_name,
                        buyDate: buydate,
                        date: date,
                        warranty: warranty,
                        price: price,
                        token: widget.token,
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
    );
  }

  Widget _buildTableView() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            showCheckboxColumn: false,
            columns: const <DataColumn>[
              DataColumn(label: Text('เลขครุภัณฑ์')),
              DataColumn(label: Text('ชื่อครุภัณฑ์')),
              DataColumn(label: Text('ยี่ห้อ')),
              DataColumn(label: Text('รุ่น')),
              DataColumn(label: Text('ผู้ถือครอง')),
              DataColumn(label: Text('สถานะ')),
              DataColumn(label: Text('ราคา')),
              DataColumn(label: Text('ระยะเวลาประกัน')),
            ],
            rows:
                filteredData.map((data) {
                  final String pricef =
                      data['eq_price'] ?? '0.00'; // เก็บ price เป็น String
                  final double parsedPrice =
                      double.tryParse(pricef) ?? 0.00; // แปลงเป็น double
                  final formattedPrice = NumberFormat(
                    "#,###.00",
                  ).format(parsedPrice);
                  final String eq_id = data['HN_id'] ?? '';
                  final String id = data['HN_id'] ?? '';
                  final String eq_name = data['eq_name'] ?? '';
                  final String brand = data['eq_brand'] ?? '';
                  final String name = data['eq_model'] ?? '';
                  final String image = (baseUrl + data["eq_img"] ?? "");
                  final String user = data['user_name'] ?? '';
                  final String type = data['eq_type'] ?? '';
                  final String price = formattedPrice;
                  final String status = data['eq_status'] ?? '';
                  final String buydate = data['eq_buydate'] ?? '';
                  final String date = data['eq_date'] ?? '';
                  final String warranty = data['eq_warran'] ?? '';

                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(id)),
                      DataCell(Text(eq_name)),
                      DataCell(Text(brand)),
                      DataCell(Text(name)),
                      DataCell(Text(user)),
                      DataCell(
                        Text(
                          status,
                          style: TextStyle(
                            color:
                                status == 'กำลังใช้งาน' || status == 'สำรอง'
                                    ? Colors.green
                                    : status == 'ระหว่างซ่อม' ||
                                        status == 'ชำรุด'
                                    ? Colors.orange
                                    : status == 'รอแทงจำหน่าย'
                                    ? Colors.red
                                    : Colors.black,
                          ),
                        ),
                      ),
                      DataCell(Text(price)),
                      DataCell(Text(warranty)),
                    ],
                    onSelectChanged: (isSelected) {
                      if (isSelected != null && isSelected) {
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
                                  buydate: buydate,
                                  date: date,
                                  warranty: warranty,
                                  status: status,
                                  token: widget.token,
                                  onRefresh: () {
                                    getrecord(widget.eqtName);
                                  },
                                ),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
