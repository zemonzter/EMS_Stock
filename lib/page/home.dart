import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/page/equipment.dart';
import 'package:ems_condb/mainten_page/mainten_report.dart';
import 'package:ems_condb/page/maintenance.dart';
import 'package:ems_condb/util/block.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'budget.dart';
import 'material.dart';

class HomePage extends StatefulWidget {
  final String? token;
  const HomePage({super.key, this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List eqtdata = [];
  List record = [];
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
        setState(() {
          userRole = user['user_role'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> getrecord() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}home.php'));
      if (response.statusCode == 200) {
        setState(() {
          eqtdata = json.decode(response.body);
          record = json.decode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getrecord();
    super.initState();
    _getUserData()
        .then((userData) {
          setState(() {
            userName = userData['name'] ?? 'User';
          });
          _fetchUserRole();
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
          });
          _fetchUserRole();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Image.asset('assets/images/logo.png', height: 100),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          double aspectRatio;

          if (Responsive.isMobile(context)) {
            crossAxisCount = 2;
            aspectRatio = 0.70;
          } else if (Responsive.isTablet(context)) {
            crossAxisCount = 2;
            aspectRatio = 1.15;
          } else {
            crossAxisCount = 2;
            aspectRatio = 1;
          }

          return _buildGridView(context, crossAxisCount, aspectRatio);
        },
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    int crossAxisCount,
    double aspectRatio,
  ) {
    return Center(
      child: SizedBox(
        width: Responsive.isMobile(context) ? double.infinity : 700,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            // childAspectRatio: 0.75,
            childAspectRatio: aspectRatio,
          ),
          itemCount: eqtdata.length,
          itemBuilder: (context, index) {
            final String id = eqtdata[index]['home_id'] ?? '';
            final String name = eqtdata[index]['home_name'] ?? '';
            final String image = (baseUrl + record[index]["home_img"] ?? "");

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 8.0)),
                    BlockDetail(
                      blockName: name,
                      blockImage: image,
                      onTap: () {
                        Widget targetPage;
                        if (id == '1') {
                          targetPage = EquipmentPage(token: widget.token);
                        } else if (id == '2') {
                          targetPage = MaterialHome(token: widget.token ?? '');
                        } else if (id == '3') {
                          if (userRole == 'Admin') {
                            targetPage = MaintenancePage(token: widget.token);
                          } else {
                            targetPage = MaintenanceReport(token: widget.token);
                          }
                        } else if (id == '4') {
                          targetPage = BudgetPage(token: widget.token);
                        } else {
                          print('Unexpected home_id: $id');
                          targetPage = const Scaffold(
                            body: Center(child: Text('Invalid Page')),
                          );
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => targetPage),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
