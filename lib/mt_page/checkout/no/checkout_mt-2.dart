import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems_condb/api_config.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String token; // Receive the token

  const CheckoutPage({super.key, required this.cartItems, required this.token});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<Map<String, dynamic>> mtdata = [];
  Map<String, dynamic> userData = {}; // Store user data

  @override
  void initState() {
    super.initState();
    getrecord();
    _fetchUserData(); // Fetch user data on initialization
  }

  Future<void> getrecord() async {
    String url =
        "${baseUrl}view_mt.php"; // Assuming you still need mtdata for _updateStock
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
        final data = json.decode(
          utf8.decode(response.bodyBytes),
        ); // Decode using UTF-8
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
    int quantity = item['quantity'].toInt();

    Map<String, dynamic>? mtItem = mtdata.firstWhere(
      (element) => element['mt_id'] == item['mt_id'],
      orElse: () => {},
    );

    if (mtItem.isNotEmpty) {
      int mtStock = int.tryParse(mtItem['mt_stock'].toString()) ?? 0;
      final url = Uri.parse(
        '${baseUrl}update_mt.php',
      ); // Assuming you have update_mt.php
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
      await _fetchUserData(); // Retry
      if (userData.isEmpty) {
        return; // Exit if still no user data
      }
    }

    // Process all items *before* showing the dialog and updating stock
    List<Map<String, dynamic>> checkoutResults = [];
    for (var item in widget.cartItems) {
      bool success = await _saveCheckoutRecord(
        item,
      ); // Save each item and get result
      if (success) {
        await _updateStock(item); // Only update stock if saving was successful
        checkoutResults.add({
          'name': item['mt_name'],
          'quantity': item['quantity'],
          'unit': item['unit_id'], // Include unit in the result
          'status': item['status'],
        });
      }
    }

    // Build a summary string for all *successful* checkouts
    String summary = "คลังวัสดุได้รับการอัปเดตแล้ว";
    // for (var result in checkoutResults) {
    //   summary += "${result['name']} ${result['quantity']} ${result['unit']}\n";
    // }
    // summary += "\nวันที่: ${DateTime.now()}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Checkout สำเร็จ'),
          content: Text(summary), // Show the summary of successful checkouts
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pop(true); // Go back to the previous screen
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _saveCheckoutRecord(Map<String, dynamic> item) async {
    final url = Uri.parse('${baseUrl}checkout.php');
    try {
      final response = await http.post(
        url,
        body: {
          'mt_name': item['mt_name'], // Send mt_name
          'username': userData['name'] ?? '', // Send username
          'quantity': item['quantity'].toString(), // Send quantity
          'unit': item['unit_id'], // Send unit_id
          'status': item['status'], // Send status
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == "true") {
          // Compare as strings
          print('Checkout record saved successfully for ${item['mt_name']}');
          return true; // Return true on success
        } else {
          print('Failed to save checkout record: ${data['message']}');
          // Optionally show an error
          return false; // Return false on failure
        }
      } else {
        print('Failed to save checkout record: Server error');
        // Optionally show an error
        return false; // Return false on server error
      }
    } catch (e) {
      print('Error saving checkout record: $e');
      // Optionally show an error
      return false; // Return false on exception
    }
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
                final unitId =
                    item['unit_id'] != null
                        ? item['unit_id']
                            .toString() // แปลงเป็น String ถ้ามี
                        : '';
                return ListTile(
                  title: Text(item['mt_name']),
                  subtitle: Text('จำนวน: ${item['quantity']}  $unitId'),
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
