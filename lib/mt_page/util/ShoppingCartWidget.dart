import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/mt_page/checkout/checkout_mt.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ShoppingCartWidget extends StatelessWidget {
  final String? token;
  final List<Map<String, dynamic>> cartItems;
  final Function(String) removeFromCart;

  const ShoppingCartWidget({
    super.key,
    required this.token,
    required this.cartItems,
    required this.removeFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            _showCartDialog(context);
          },
        ),
        if (cartItems.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                cartItems.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ตะกร้าสินค้า',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.mali().fontFamily,
                      ),
                    ),
                    if (cartItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'ไม่มีสินค้าในตะกร้า',
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return ListTile(
                              title: Text(
                                item['mt_name'],
                                style: TextStyle(
                                  fontFamily: GoogleFonts.mali().fontFamily,
                                ),
                              ),
                              subtitle: Text(
                                'จำนวน: ${item['quantity']} ${item['unit_id']}',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.mali().fontFamily,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    removeFromCart(item['mt_id']);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (cartItems.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog first
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CheckoutPage(
                                    cartItems: cartItems,
                                    token: token,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E0101),
                        ),
                        child: Text(
                          'ดำเนินการต่อ',
                          style: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
