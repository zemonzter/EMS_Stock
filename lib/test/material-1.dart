import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/mt_page/insert_mt.dart';
import 'package:ems_condb/mt_page/show_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../mt_page/checkout/checkout_mt.dart';

class MaterialsPage extends StatefulWidget {
  final String token;
  const MaterialsPage({super.key, required this.token});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  List<Map<String, dynamic>> mtdata = [];
  List<Map<String, dynamic>> filteredData = [];
  String searchText = '';
  List<Map<String, dynamic>> cartItems = [];
  final Map<String, int> _quantities = {}; // ใช้สำหรับจัดการจำนวนสินค้าแต่ละตัว

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_mt.php";
    try {
      var response = await http.get(Uri.parse(uri));
      setState(() {
        mtdata = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        filteredData = mtdata; // Initially, show all data
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getrecord();
    super.initState();
  }

  void _addToCart(Map<String, dynamic> item) {
    int availableStock =
        int.tryParse(item['mt_stock'].toString()) ?? 0; // Get available stock
    int quantityToAdd = _quantities[item['mt_id']] ?? 1;

    if (quantityToAdd > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only $availableStock ${item['unit_id']} of ${item['mt_name']} are available.',
          ),
        ),
      );
      return; // Don't add to cart if exceeding stock
    }

    setState(() {
      bool itemExists = false;

      for (var cartItem in cartItems) {
        if (cartItem['mt_id'] == item['mt_id']) {
          cartItem['quantity'] = (cartItem['quantity'] ?? 0) + quantityToAdd;
          itemExists = true;
          break;
        }
      }

      if (!itemExists) {
        cartItems.add({
          'mt_id': item['mt_id'],
          'mt_name': item['mt_name'],
          'quantity': quantityToAdd,
        });
      }

      _quantities[item['mt_id']] = 1; // Reset quantity after adding
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['mt_name']} added to cart!')),
    );
  }

  void _incrementQuantity(String id, int availableStock) {
    setState(() {
      if ((_quantities[id] ?? 1) < availableStock) {
        // Check against available stock
        _quantities[id] = (_quantities[id] ?? 1) + 1;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum quantity reached')),
        );
      }
    });
  }

  void _decrementQuantity(String id) {
    setState(() {
      if ((_quantities[id] ?? 1) > 1) {
        _quantities[id] = (_quantities[id] ?? 1) - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("วัสดุ", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsertMT()),
              );
            },
            icon: const Icon(Icons.add),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  // แสดงตะกร้าใน Dialog
                  final result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Cart Items'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return ListTile(
                                title: Text(item['mt_name']),
                                subtitle: Text('Quantity: ${item['quantity']}'),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              final checkoutResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CheckoutPage(
                                        cartItems: cartItems,
                                        token: widget.token,
                                      ),
                                ),
                              );
                              if (checkoutResult == true) {
                                // ตรวจสอบค่าที่ส่งกลับ
                                setState(() {
                                  cartItems.clear(); // ล้าง cartItems
                                  _quantities.clear(); // ล้าง _quantities
                                });
                              }
                              getrecord();
                            },
                            child: const Text(
                              'เบิกวัสดุ',
                            ), // เปลี่ยนเป็น 'เบิกวัสดุ'
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              Positioned(
                top: 3.0,
                right: 4.0,
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: const ShapeDecoration(
                    color: Colors.red,
                    shape: CircleBorder(),
                  ),
                  child: Text(
                    cartItems
                        .fold<int>(
                          0,
                          (sum, item) => sum + (item['quantity'] as int),
                        )
                        .toString(),
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  filteredData =
                      mtdata
                          .where(
                            (item) => item['mt_name'].toLowerCase().contains(
                              searchText.toLowerCase(),
                            ),
                          )
                          .toList();
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                final String id = item['mt_id'] ?? '';
                final String name = item['mt_name'] ?? '';
                final String image = (baseUrl + item["mt_img"] ?? '');
                final String stock = "${item["mt_stock"]} ${item["unit_id"]}";
                final int stockValue =
                    int.tryParse(item["mt_stock"].toString()) ?? 0;

                final TextStyle stockTextStyle =
                    stockValue == 0
                        ? const TextStyle(color: Colors.red)
                        : const TextStyle(color: Colors.black);

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ShowDetail(
                                  id: id,
                                  name: name,
                                  image: image,
                                  stock: item['mt_stock'] ?? '',
                                  unit: item['unit_id'] ?? '',
                                  url: item['mt_url'],
                                ),
                          ),
                        );
                      },
                      child: Image.network(
                        image,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.error)),
                      ),
                    ),
                    Text(name, overflow: TextOverflow.ellipsis),
                    Text(stock, style: stockTextStyle),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _decrementQuantity(id),
                        ),
                        Text(
                          '${_quantities[id] ?? 1}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            int availableStock =
                                int.tryParse(item['mt_stock'].toString()) ?? 0;
                            _incrementQuantity(id, availableStock);
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(item),
                      child: const Text('Add to Cart'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
