import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<Map<String, dynamic>> mtdata = [];

  @override
  void initState() {
    super.initState();
    getrecord();
  }

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_mt.php";
    try {
      var response = await http.get(Uri.parse(uri));
      setState(() {
        mtdata = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _updateStock(Map<String, dynamic> item) async {
    int quantity = item['quantity'].toInt();

    // ค้นหา mt_stock จาก mtdata โดยใช้ mt_id
    Map<String, dynamic>? mtItem = mtdata.firstWhere(
      (element) => element['mt_id'] == item['mt_id'],
      orElse: () => {},
    );

    if (mtItem.isNotEmpty) {
      int mtStock =
          int.tryParse(mtItem['mt_stock'].toString()) ??
          0; // แปลงเป็น int อย่างปลอดภัย
      final url = Uri.parse('http://127.0.0.1/ems_dbcon/update_mt.php');
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
    for (var item in widget.cartItems) {
      await _updateStock(item);
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Checkout สำเร็จ'),
          content: const Text('สต็อกสินค้าได้รับการอัปเดตแล้ว'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return ListTile(
                  title: Text(item['mt_name']),
                  subtitle: Text('จำนวน: ${item['quantity']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _checkout,
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}
