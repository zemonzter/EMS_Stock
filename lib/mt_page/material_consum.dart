import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/mt_page/insert_mt.dart';
import 'package:ems_condb/mt_page/show_detail.dart';
import 'package:ems_condb/mt_page/util/ShoppingCartWidget.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'checkout/checkout_mt.dart';

class MaterialsPage extends StatefulWidget {
  final String? token;
  const MaterialsPage({super.key, required this.token});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  List<Map<String, dynamic>> mtdata = [];
  List<Map<String, dynamic>> filteredData = [];
  String searchText = '';
  List<Map<String, dynamic>> cartItems = [];
  final Map<String, int> _quantities = {};
  String _sortOrder = 'id';
  bool _showOnlyInStock = false;
  bool _isLoading = true;
  String userName = '';
  String userRole = '';

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
        if (mounted) {
          setState(() {
            userRole = user['user_role'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_mt.php";
    try {
      var response = await http.get(Uri.parse(uri));
      if (mounted) {
        setState(() {
          mtdata = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _sortData();
          filteredData = mtdata;
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sortData() {
    List<Map<String, dynamic>> tempData = List.from(mtdata);

    switch (_sortOrder) {
      case 'id':
        tempData.sort(
          (a, b) => (int.parse(a['mt_id'])).compareTo(int.parse(b['mt_id'])),
        );
        break;
      case 'stock_asc':
        tempData.sort((a, b) {
          int stockA = int.tryParse(a['mt_stock'].toString()) ?? 0;
          int stockB = int.tryParse(b['mt_stock'].toString()) ?? 0;
          return stockA.compareTo(stockB);
        });
        break;
      case 'stock_desc':
        tempData.sort((a, b) {
          int stockA = int.tryParse(a['mt_stock'].toString()) ?? 0;
          int stockB = int.tryParse(b['mt_stock'].toString()) ?? 0;
          return stockB.compareTo(stockA);
        });
        break;
    }

    if (_showOnlyInStock) {
      tempData =
          tempData.where((item) {
            int stock = int.tryParse(item['mt_stock'].toString()) ?? 0;
            return stock > 0;
          }).toList();
    }

    if (searchText.isNotEmpty) {
      filteredData =
          tempData
              .where(
                (item) => item['mt_name'].toLowerCase().contains(
                  searchText.toLowerCase(),
                ),
              )
              .toList();
    } else {
      filteredData = tempData;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData()
        .then((userData) {
          if (mounted) {
            setState(() {
              userName = userData['name'] ?? 'User';
              _isLoading = false;
            });
          }
          _fetchUserRole().then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          if (mounted) {
            setState(() {
              userName = 'User';
              _isLoading = false;
            });
          }
          _fetchUserRole().then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        });

    getrecord();
  }

  // Function to get the available stock for a given item
  int _getAvailableStock(String mtId) {
    for (var item in mtdata) {
      if (item['mt_id'] == mtId) {
        return int.tryParse(item['mt_stock'].toString()) ?? 0;
      }
    }
    return 0;
  }

  void _addToCart(Map<String, dynamic> item) {
    String mtId = item['mt_id'];
    int availableStock = _getAvailableStock(mtId);
    int quantityToAdd = _quantities[mtId] ?? 1;

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
            style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
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
          'unit_id': item['unit_id'],
        });
      }
      _quantities[item['mt_id']] = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item['mt_name']} เพิ่มลงตะกร้าสำเร็จ!',
          style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
        ),
      ),
    );
  }

  void _incrementQuantity(String id, int availableStock) {
    int currentCartQuantity = 0;
    for (var cartItem in cartItems) {
      if (cartItem['mt_id'] == id) {
        currentCartQuantity = cartItem['quantity'] ?? 0;
        break;
      }
    }

    setState(() {
      if ((_quantities[id] ?? 1) + currentCartQuantity < availableStock) {
        _quantities[id] = (_quantities[id] ?? 1) + 1;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ถึงปริมาณสูงสุดแล้ว',
              style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
            ),
          ),
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

  void _removeFromCart(String mtId) {
    setState(() {
      cartItems.removeWhere((item) => item['mt_id'] == mtId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ลบรายการวัสดุออกจากตะกร้าสำเร็จ!',
          style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "วัสดุ",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.mali().fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (userRole == 'Admin')
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InsertMT()),
                );
                getrecord();
              },
              icon: const Icon(Icons.add),
            ),
          ShoppingCartWidget(
            // ใช้ ShoppingCartWidget ที่สร้างไว้
            token: widget.token,
            cartItems: cartItems,
            removeFromCart: (itemId) {
              setState(() {
                cartItems.removeWhere((item) => item['mt_id'] == itemId);
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width:
              Responsive.isDesktop(context)
                  ? 1100
                  : Responsive.isTablet(context)
                  ? 700
                  : double.infinity,
          child: Column(
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
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                                  title: Text(
                                    'จำนวน (น้อยไปมาก)',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.mali().fontFamily,
                                    ),
                                  ),
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
                                  title: Text(
                                    'จำนวน (มากไปน้อย)',
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.mali().fontFamily,
                                    ),
                                  ),
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
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Text(
                                      'แสดงเฉพาะวัสดุที่มีอยู่ในคลัง',
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.mali().fontFamily,
                                      ),
                                    ),
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
                                crossAxisCount:
                                    Responsive.isMobile(context)
                                        ? 2
                                        : Responsive.isTablet(context)
                                        ? 3
                                        : 4,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];
                            final String id = item['mt_id'] ?? '';
                            final String name = item['mt_name'] ?? '';
                            final String image =
                                (baseUrl + item["mt_img"] ?? '');
                            final String stock =
                                "${item["mt_stock"]} ${item["unit_id"]}";
                            final int stockValue =
                                int.tryParse(item["mt_stock"].toString()) ?? 0;

                            final TextStyle stockTextStyle =
                                stockValue == 0
                                    ? const TextStyle(color: Colors.red)
                                    : const TextStyle(color: Colors.black);

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
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
                                                token: widget.token,
                                              ),
                                        ),
                                      );
                                      getrecord();
                                    },
                                    child: Image.network(
                                      image,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                child: Icon(Icons.error),
                                              ),
                                    ),
                                  ),
                                  Text(name, overflow: TextOverflow.ellipsis),
                                  Text(stock, style: stockTextStyle),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => _decrementQuantity(id),
                                      ),
                                      // SizedBox(
                                      //   width: 40,
                                      //   height: 40,
                                      //   child: TextField(
                                      //     keyboardType: TextInputType.number,
                                      //     textAlign: TextAlign.center,
                                      //     decoration: InputDecoration(
                                      //       border: OutlineInputBorder(),
                                      //       contentPadding:
                                      //           EdgeInsets.symmetric(
                                      //             vertical: 8,
                                      //           ),
                                      //     ),
                                      //     controller: TextEditingController(
                                      //       text: '${_quantities[id] ?? 1}',
                                      //     ),
                                      //     onChanged: (value) {
                                      //       int? quantity = int.tryParse(value);
                                      //       if (quantity != null &&
                                      //           quantity >= 1) {
                                      //         // ตรวจสอบว่าจำนวนไม่น้อยกว่า 1
                                      //         _quantities[id] = quantity;
                                      //       }
                                      //     },
                                      //   ),
                                      // ),
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                          ),
                                          controller: TextEditingController(
                                            text: '${_quantities[id] ?? 1}',
                                          ),
                                          onChanged: (value) {
                                            int availableStock =
                                                int.tryParse(
                                                  item['mt_stock'].toString(),
                                                ) ??
                                                0;
                                            int? quantity = int.tryParse(value);
                                            // if (quantity != null &&
                                            //         quantity >= 1 &&
                                            //         quantity <=
                                            //             int.tryParse(
                                            //               item['mt_stock']
                                            //                   .toString(),
                                            //             ) ??
                                            //     0)
                                            // {
                                            if (quantity != null &&
                                                quantity >= 1 &&
                                                quantity <= availableStock) {
                                              // Add stock limit check
                                              _quantities[id] = quantity!;
                                            } else {
                                              // Optionally, reset the value to the previous valid quantity
                                              if (quantity != null &&
                                                  quantity > availableStock) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'ไม่สามารถเพิ่มจำนวนวัสดุได้  ${item['mt_name']} มีจำนวน $availableStock ${item['unit_id']}!',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            GoogleFonts.mali()
                                                                .fontFamily,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                                _quantities[id] =
                                                    int.tryParse(
                                                      item['mt_stock']
                                                          .toString(),
                                                    ) ??
                                                    0;
                                                TextEditingController(
                                                  text:
                                                      '${_quantities[id] ?? 1}',
                                                );
                                              } else if (quantity != null &&
                                                  quantity < 1) {
                                                _quantities[id] = 1;
                                                TextEditingController(
                                                  text:
                                                      '${_quantities[id] ?? 1}',
                                                );
                                              }
                                              setState(() {});
                                            }
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          int availableStock =
                                              int.tryParse(
                                                item['mt_stock'].toString(),
                                              ) ??
                                              0;
                                          _incrementQuantity(
                                            id,
                                            availableStock,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _addToCart(item),
                                    child: Text(
                                      'เพิ่มลงตะกร้า',
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.mali().fontFamily,
                                      ),
                                    ),
                                  ),
                                ],
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
