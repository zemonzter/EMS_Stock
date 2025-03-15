import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_mt.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import '../util/font.dart';

class ShowDetail extends StatefulWidget {
  final String id;
  String name; // Make these non-final
  String image;
  String stock;
  String unit;
  String url;
  String? token;

  ShowDetail({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.stock,
    required this.unit,
    required this.url,
    required this.token,
  });

  @override
  State<ShowDetail> createState() => _ShowDetailState();
}

class _ShowDetailState extends State<ShowDetail> {
  int _quantity = 1;
  bool _isLoading = false; // Add a loading indicator
  String userName = '';
  String userRole = ''; // เพิ่ม userRole

  Future<void> _launchUrl() async {
    if (widget.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่มีข้อมูลเพิ่มเติมสำหรับวัสดุนี้!')),
      );
      return;
    }

    if (!await launchUrl(Uri.parse(widget.url))) {
      throw Exception('Could not launch ${widget.url}');
    }
  }

  // Use a callback for refresh
  Future<void> _navigateToEditPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditMtPage(
              id: widget.id,
              name: widget.name,
              stock: widget.stock,
              unit: widget.unit,
              imageUrl: widget.image,
              url: widget.url,
              onUpdate: (newName, newStock, newUnit) {
                // This is where we update the ShowDetail's state.
                if (mounted) {
                  setState(() {
                    widget.name = newName;
                    widget.stock = newStock;
                    widget.unit = newUnit;
                  });
                }
              },
            ),
      ),
    );
  }

  // Correct _refreshData implementation.  Fetches data from API.
  Future<void> _refreshData() async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      _isLoading = true; // Show loader
    });
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_mt_details.php?id=${widget.id}',
        ), // Your API endpoint
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Update the STATE variables, not the widget properties.
        if (mounted) {
          // Check again before setting state
          setState(() {
            widget.name = jsonData['mt_name']; // Use widget.name, etc.
            widget.stock = jsonData['mt_stock'].toString();
            widget.unit = jsonData['mt_unit']; // Also refresh the unit.
            _isLoading = false; // Hide loader
            // _refreshData(); // Refresh data after updating  <- REMOVE THIS LINE.  It's causing an infinite loop.
          });
        }
      } else {
        if (mounted) {
          // Check before showing dialog
          // _showDialog(context, "Error", "Server error: ${response.statusCode}");
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Check before showing dialog
        _showDialog(context, "Error", "Exception: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // No changes needed here.
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // @override
  // void initState() {
  //   super.initState();

  //   _refreshData(); // Load data when the widget is created.
  // }

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
            _refreshData();
          });
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
          });
          _fetchUserRole().then((_) {
            _refreshData();
          });
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            widget.name, // Use widget.name, etc. - they're now mutable
            style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
          ),
        ),
      ),
      body:
          _isLoading // Show loading indicator while fetching data
              ? Center(child: CircularProgressIndicator())
              : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      width:
                          Responsive.isDesktop(context)
                              ? 1000
                              : double.infinity,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    widget.image,
                                    width: 400,
                                    height: 350,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(Icons.error),
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                widget.name, // Use widget.name, etc.
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'คงเหลือ: ${widget.stock} ${widget.unit}', // Use widget.stock, etc.
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              const Divider(thickness: 1.0),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton(
                                    onPressed: _launchUrl,
                                    child: Text(
                                      'ข้อมูลเพิ่มเติม',
                                      style: TextStyle(
                                        fontFamily: Fonts.Fontnormal.fontFamily,
                                        fontSize:
                                            Responsive.isDesktop(context)
                                                ? 22.0
                                                : 16.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  if (userRole == 'Admin')
                                    ElevatedButton(
                                      onPressed:
                                          () => _navigateToEditPage(context),
                                      style: ElevatedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        'แก้ไขข้อมูล',
                                        style: TextStyle(
                                          fontFamily:
                                              Fonts.Fontnormal.fontFamily,
                                          fontSize:
                                              Responsive.isDesktop(context)
                                                  ? 22.0
                                                  : 16.0,
                                        ),
                                      ),
                                    ),
                                  // OutlinedButton(
                                  //   onPressed: _launchUrl,
                                  //   child: Text(
                                  //     'ข้อมูลเพิ่มเติม',
                                  //     style: TextStyle(
                                  //       fontFamily: Fonts.Fontnormal.fontFamily,
                                  //     ),
                                  //   ),
                                  // ),
                                  // ElevatedButton(
                                  //   onPressed: () => _navigateToEditPage(context),
                                  //   child: Text(
                                  //     'แก้ไขข้อมูล',
                                  //     style: TextStyle(
                                  //       fontFamily: Fonts.Fontnormal.fontFamily,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  void _incrementQuantity() {
    if (_quantity < int.parse(widget.stock)) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }
}
