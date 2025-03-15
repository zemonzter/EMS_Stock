import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems_condb/api_config.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String token;

  const CheckoutPage({super.key, required this.cartItems, required this.token});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<Map<String, dynamic>> mtdata = [];
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    getrecord();
    _fetchUserData();
  }

  Future<void> getrecord() async {
    String url = "${baseUrl}view_mt.php";
    try {
      var response = await http.get(Uri.parse(url));
      setState(() {
        mtdata = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchUserData() async {
    final userUrl = Uri.parse(
      'https://api.rmutsv.ac.th/elogin/token/${widget.token}',
    );
    try {
      final response = await http.get(userUrl);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          userData = data;
        });
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateStock(Map<String, dynamic> item) async {
    // โค้ดเดิมสำหรับการอัพเดทสต็อก
    int quantity = item['quantity'].toInt();

    Map<String, dynamic>? mtItem = mtdata.firstWhere(
      (element) => element['mt_id'] == item['mt_id'],
      orElse: () => {},
    );

    if (mtItem.isNotEmpty) {
      int mtStock = int.tryParse(mtItem['mt_stock'].toString()) ?? 0;
      final url = Uri.parse('${baseUrl}update_mt.php');
      try {
        final response = await http.post(
          url,
          body: {
            'mt_id': item['mt_id'].toString(),
            'mt_stock': (mtStock - quantity).toString(),
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success']) {
            print('Stock updated successfully for ${item['mt_name']}');
          } else {
            print('Failed to update stock: ${data['message']}');
          }
        } else {
          print('Failed to update stock: Server error');
        }
      } catch (e) {
        print('Error updating stock: $e');
      }
    } else {
      print('Material not found in database for ${item['mt_name']}');
    }
  }

  Future<void> _checkout() async {
    if (userData.isEmpty) {
      print("User data not loaded yet.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data is loading, please wait.')),
      );
      await _fetchUserData();
      if (userData.isEmpty) {
        return;
      }
    }

    // ส่งคำขออนุมัติ
    final url = Uri.parse('${baseUrl}request_approval.php');
    try {
      final response = await http.post(
        url,
        body: {
          'username': userData['name'] ?? '',
          'items': jsonEncode(widget.cartItems),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == "true") {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'คำขออนุมัติถูกส่งแล้ว',
                  style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
                ),
                content: Text(
                  'รอการอนุมัติจากผู้ดูแลระบบ',
                  style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'ตกลง',
                      style: TextStyle(
                        fontFamily: GoogleFonts.mali().fontFamily,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to request approval: ${data['message']}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to server')),
        );
      }
    } catch (e) {
      // print('Error requesting approval: $e');
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Error: $e')));
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'คำขออนุมัติถูกส่งแล้ว',
              style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
            ),
            content: Text(
              'รอการอนุมัติจากผู้ดูแลระบบ',
              style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'ตกลง',
                  style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  // โค้ด _saveCheckoutRecord() และ build() เดิม
  Future<bool> _saveCheckoutRecord(Map<String, dynamic> item) async {
    final url = Uri.parse('${baseUrl}checkout.php');
    try {
      final response = await http.post(
        url,
        body: {
          'mt_name': item['mt_name'],
          'username': userData['name'] ?? '',
          'quantity': item['quantity'].toString(),
          'unit': item['unit_id'],
          'status': item['status'],
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == "true") {
          print('Checkout record saved successfully for ${item['mt_name']}');
          return true;
        } else {
          print('Failed to save checkout record: ${data['message']}');
          return false;
        }
      } else {
        print('Failed to save checkout record: Server error');
        return false;
      }
    } catch (e) {
      print('Error saving checkout record: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: Responsive.isDesktop(context) ? 1000 : double.infinity,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    final unitId =
                        item['unit_id'] != null
                            ? item['unit_id'].toString()
                            : '';
                    return Card(
                      // ห่อ ListTile ด้วย Card
                      elevation: 2, // เพิ่มเงาเล็กน้อย
                      margin: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ), // เพิ่มระยะขอบ
                      child: ListTile(
                        title: Text(
                          item['mt_name'],
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                        subtitle: Text(
                          'จำนวน: ${item['quantity']} $unitId',
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _checkout,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ), // ระยะขอบภายในปุ่ม
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8.0,
                      ), // รัศมีมุมโค้งของปุ่ม
                    ),
                    elevation: 5, // เพิ่มเงาให้กับปุ่ม
                  ),
                  child: Text(
                    'Checkout',
                    style: TextStyle(
                      fontFamily: GoogleFonts.mali().fontFamily,
                      fontSize: 18, // ขนาดตัวอักษร
                      fontWeight: FontWeight.bold, // ความหนาตัวอักษร
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
