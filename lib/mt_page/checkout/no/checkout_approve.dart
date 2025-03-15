import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CheckoutApprovePage extends StatefulWidget {
  final String? token;
  const CheckoutApprovePage({super.key, this.token});

  @override
  State<CheckoutApprovePage> createState() => _CheckoutApprovePageState();
}

class _CheckoutApprovePageState extends State<CheckoutApprovePage> {
  List<Map<String, dynamic>> checkoutRequests = [];
  List<Map<String, dynamic>> mtdata = []; // Store material data here

  @override
  void initState() {
    super.initState();
    _fetchCheckoutRequests();
    _fetchMaterialData(); // Fetch material data on initialization
  }

  Future<void> _fetchMaterialData() async {
    String url = "${baseUrl}view_mt.php"; // Assuming you have a view_mt.php
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          setState(() {
            mtdata = List<Map<String, dynamic>>.from(decodedData);
          });
        } else {
          print('Unexpected response format (view_mt.php): $decodedData');
        }
      } else {
        print('Failed to fetch material data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching material data: $e');
    }
  }

  Future<void> _fetchCheckoutRequests() async {
    String url = "${baseUrl}view_checkout_report.php";
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          setState(() {
            checkoutRequests =
                List<Map<String, dynamic>>.from(
                  decodedData,
                ).where((item) => item['status'] == 'pending').toList();
          });
        } else {
          print('Unexpected response format: $decodedData');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Unexpected response format')));
        }
      } else {
        print('Failed to fetch checkout requests: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load requests: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching checkout requests: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading requests: $e')));
    }
  }

  Future<void> _updateCheckoutStatus(
    int checkoutId,
    int index,
    String newStatus,
  ) async {
    String url = "${baseUrl}update_checkout_status.php";
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {'checkout_id': checkoutId.toString(), 'status': newStatus},
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            if (newStatus == 'approved') {
              // Get request for update stock
              Map<String, dynamic> request = checkoutRequests[index];
              await _updateStockAfterApproval(request);
            }
            // _fetchCheckoutRequests(); // Reload after *successful* update.  Better UX.

            // Remove the item from the list immediately, so the UI updates instantly.
            setState(() {
              checkoutRequests.removeAt(index);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Checkout $newStatus successfully!')),
            );
          } else {
            print('Failed to update checkout: ${data['message']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update: ${data['message']}')),
            );
          }
        } else {
          print("Empty response from update_checkout_status.php");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server returned empty response (update status)"),
            ),
          );
        }
      } else {
        print('Failed to update checkout status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update checkout status: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      // print('Error updating checkout status: $e');
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }

  Future<void> _approveCheckout(int checkoutId, int index) async {
    await _updateCheckoutStatus(checkoutId, index, 'approved');
  }

  Future<void> _rejectCheckout(int checkoutId, int index) async {
    await _updateCheckoutStatus(checkoutId, index, 'rejected');
  }

  Future<void> _updateStockAfterApproval(Map<String, dynamic> item) async {
    int quantity = item['quantity'].toInt();

    // Find the material in the local mtdata list.  No need for a DB query if we have the data.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout Approval',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          checkoutRequests.isEmpty
              ? const Center(child: Text('ไม่มีข้อมูล'))
              : ListView.builder(
                itemCount: checkoutRequests.length,
                itemBuilder: (context, index) {
                  final request = checkoutRequests[index];
                  final formattedDate = DateFormat(
                    'dd MMM yyy',
                  ).format(DateTime.parse(request['date']));
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Material: ${request['mt_name']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('User: ${request['username']}'),
                          Text(
                            'Quantity: ${request['quantity']} ${request['unit']}',
                          ),
                          Text('Date: $formattedDate'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed:
                                    () => _approveCheckout(
                                      int.parse(request['checkout_id']),
                                      index,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed:
                                    () => _rejectCheckout(
                                      int.parse(request['checkout_id']),
                                      index,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(color: Colors.white),
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
    );
  }
}
