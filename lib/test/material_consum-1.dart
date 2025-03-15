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
  String _sortOrder = 'id'; // Default sort by ID
  bool _showOnlyInStock = false; // Added variable

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_mt.php";
    try {
      var response = await http.get(Uri.parse(uri));
      setState(() {
        mtdata = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _sortData(); // Sort data after fetching
        filteredData = mtdata; // Initially, show all data
      });
    } catch (e) {
      print(e);
    }
  }

  void _sortData() {
    switch (_sortOrder) {
      case 'id':
        mtdata.sort(
          (a, b) => (int.parse(a['mt_id'])).compareTo(int.parse(b['mt_id'])),
        );
        break;
      case 'stock_asc':
        mtdata.sort((a, b) {
          int stockA = int.tryParse(a['mt_stock'].toString()) ?? 0;
          int stockB = int.tryParse(b['mt_stock'].toString()) ?? 0;
          return stockA.compareTo(stockB);
        });
        break;
      case 'stock_desc':
        mtdata.sort((a, b) {
          int stockA = int.tryParse(a['mt_stock'].toString()) ?? 0;
          int stockB = int.tryParse(b['mt_stock'].toString()) ?? 0;
          return stockB.compareTo(stockA);
        });
        break;
    }

    if (_showOnlyInStock) {
      // Added condition
      mtdata =
          mtdata.where((item) {
            int stock = int.tryParse(item['mt_stock'].toString()) ?? 0;
            return stock > 0;
          }).toList();
    } else {
      getrecord();
    }

    if (searchText.isNotEmpty) {
      filteredData =
          mtdata
              .where(
                (item) => item['mt_name'].toLowerCase().contains(
                  searchText.toLowerCase(),
                ),
              )
              .toList();
    } else {
      filteredData = mtdata;
    }
  }

  @override
  void initState() {
    getrecord();
    super.initState();
  }

  // Function to get the available stock for a given item
  int _getAvailableStock(String mtId) {
    for (var item in mtdata) {
      if (item['mt_id'] == mtId) {
        return int.tryParse(item['mt_stock'].toString()) ?? 0;
      }
    }
    return 0; // Return 0 if item not found (shouldn't happen)
  }

  void _addToCart(Map<String, dynamic> item) {
    String mtId = item['mt_id'];
    int availableStock = _getAvailableStock(mtId);
    int quantityToAdd = _quantities[mtId] ?? 1;

    // Check if adding this quantity would exceed the stock
    int currentCartQuantity = 0;
    for (var cartItem in cartItems) {
      if (cartItem['mt_id'] == mtId) {
        currentCartQuantity = cartItem['quantity'] ?? 0;
        break;
      }
    }

    if (currentCartQuantity + quantityToAdd > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ไม่สามารถเพิ่มจำนวนวัสดุได้  ${item['mt_name']} มีจำนวน $availableStock ${item['unit_id']}!',
          ),
        ),
      );
      return;
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
      _quantities[item['mt_id']] = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['mt_name']} added to cart!')),
    );
  }

  void _incrementQuantity(String id, int availableStock) {
    // Find the item in the cart
    int currentCartQuantity = 0;
    for (var cartItem in cartItems) {
      if (cartItem['mt_id'] == id) {
        currentCartQuantity = cartItem['quantity'] ?? 0;
        break;
      }
    }

    setState(() {
      // Check if adding one more would exceed the stock, considering cart quantity
      if ((_quantities[id] ?? 1) + currentCartQuantity < availableStock) {
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

  // Function to remove an item from the cart
  void _removeFromCart(String mtId) {
    setState(() {
      cartItems.removeWhere((item) => item['mt_id'] == mtId);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
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
                  if (cartItems.isEmpty) {
                    // เพิ่มเช็คตรงนี้
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('โปรดเลือกวัสดุที่ต้องการเบิก'),
                      ),
                    );
                    return; // หยุดการทำงานถ้า cart ว่าง
                  }
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
                                // Add a delete button here
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _removeFromCart(item['mt_id']);
                                    Navigator.of(context).pop(); // Close dialog
                                    showDialog(
                                      // Re-open dialog (refresh)
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
                                                  subtitle: Text(
                                                    'Quantity: ${item['quantity']}',
                                                  ),
                                                  // Add a delete button here
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                    ),
                                                    onPressed: () {
                                                      _removeFromCart(
                                                        item['mt_id'],
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // Close dialog
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                final checkoutResult =
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => CheckoutPage(
                                                              cartItems:
                                                                  cartItems,
                                                              token:
                                                                  widget.token,
                                                            ),
                                                      ),
                                                    );
                                                if (checkoutResult == true) {
                                                  // ตรวจสอบค่าที่ส่งกลับ
                                                  setState(() {
                                                    cartItems
                                                        .clear(); // ล้าง cartItems
                                                    _quantities
                                                        .clear(); // ล้าง _quantities
                                                  });
                                                }
                                                getrecord();
                                              },
                                              child: const Text('เบิกวัสดุ'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
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
                            child: const Text('เบิกวัสดุ'),
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
                  _sortData();
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

          // Sort Button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // const Text("Sort by:"),
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.arrow_upward),
                              title: const Text('จำนวน (น้อยไปมาก)'),
                              onTap: () {
                                setState(() {
                                  _sortOrder = 'stock_asc';
                                  _sortData();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_downward),
                              title: const Text('จำนวน (มากไปน้อย)'),
                              onTap: () {
                                setState(() {
                                  _sortOrder = 'stock_desc';
                                  _sortData();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _showOnlyInStock,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _showOnlyInStock = value ?? false;
                                      _sortData();
                                      getrecord();
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                const Text('แสดงเฉพาะวัสดุที่มีอยู่ในคลัง'),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
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
