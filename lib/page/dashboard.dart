import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/dashboard/BarChart.dart';
import 'package:ems_condb/dashboard/pieEQchart.dart';
import 'package:ems_condb/dashboard/pieMTChart.dart';
import 'package:ems_condb/mainten_page/admin_maintenance.dart';
import 'package:ems_condb/mainten_page/mainten_report.dart';
import 'package:ems_condb/mt_page/checkout/admin_ap.dart';
import 'package:ems_condb/mt_page/checkout/checkout_mt_report.dart';
import 'package:ems_condb/page/equipment.dart';
import 'package:ems_condb/page/material.dart';
import 'package:ems_condb/util/color.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../dashboard/PieChart.dart';

//

class DashboardPage extends StatefulWidget {
  final String? token;
  const DashboardPage({super.key, required this.token});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<BarChartGroupData> _barGroups = [];
  List<PieChartSectionData> _pieSections = [];
  List<PieChartSectionData> _pieEQSections = [];
  List<PieChartSectionData> _pieMTSections = [];
  bool _isLoading = true;
  final List<String> _months = [];
  final List<String> _years = [];
  int _totalCheckoutCount = 0;
  int _totalMaintenCount = 0;
  int _totalEqCount = 0;
  int _totalMtCount = 0;
  int _totalOrderCount = 0;

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
          _isLoading = false; // Set loading to false
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        _isLoading = false; // Set loading to false on error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData()
        .then((userData) {
          setState(() {
            userName = userData['name'] ?? 'User';
          });
          _fetchUserRole(); // Just call it
          fetchChartData();
        })
        .catchError((error) {
          print('Error fetching user data: $error');
          setState(() {
            userName = 'User';
            _isLoading = false; // Set loading to false on error
          });
          _fetchUserRole(); // Call it here too
          fetchChartData();
        });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchChartData();
  // }

  Future<void> fetchChartData() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}dashboard.php'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        _totalOrderCount = jsonData.fold<int>(
          0,
          (sum, item) => sum + int.parse(item['order_count'].toString()),
        );

        double totalCount = jsonData.fold<double>(
          0,
          (sum, item) => sum + double.parse(item['order_count'].toString()),
        );

        _barGroups =
            jsonData.asMap().entries.map((entry) {
              final int index = entry.key;
              final dynamic item = entry.value;
              _months.add(item['month']);
              print(item['month']);

              Color barColor =
                  AppColors.chartColors[index % AppColors.chartColors.length];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: double.parse(item['order_count'].toString()),
                    color: barColor,
                    width: 25,
                  ),
                ],
              );
            }).toList();

        _pieSections =
            jsonData.asMap().entries.map((entry) {
              final int index = entry.key;
              final dynamic item = entry.value;
              final double percentage =
                  double.parse(item['order_count'].toString()) / totalCount;
              Color pieColor =
                  AppColors.chartColors[index % AppColors.chartColors.length];
              return PieChartSectionData(
                value: percentage,
                title: '${(percentage * 100).toInt()}%',
                color: pieColor,
                radius: 50,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              );
            }).toList();

        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }

    try {
      final response = await http.get(Uri.parse('${baseUrl}mainten_graph.php'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _totalMaintenCount = jsonData.fold<int>(
          0,
          (sum, item) => sum + int.parse(item['mainten_count'].toString()),
        );
        double totalMaintCount = jsonData.fold<double>(
          0,
          (sum, item) => sum + double.parse(item['mainten_count']),
        );
        // _barGroups =
        //     jsonData.asMap().entries.map((entry) {
        //       final int index = entry.key;
        //       final dynamic item = entry.value;
        //       _months.add(item['month']);
        //       Color barColor =
        //           AppColors.chartColors[index % AppColors.chartColors.length];
        //       return BarChartGroupData(
        //         x: index,
        //         barRods: [
        //           BarChartRodData(
        //             toY: double.parse(item['mainten_count'].toString()),
        //             color: barColor,
        //             width: 25,
        //           ),
        //         ],
        //       );
        //     }).toList();

        // _pieSections =
        //     jsonData.asMap().entries.map((entry) {
        //       final int index = entry.key;
        //       final dynamic item = entry.value;
        //       final double percentage =
        //           double.parse(item['mainten_count']) / totalMaintCount;
        //       Color pieColor =
        //           AppColors.chartColors[index % AppColors.chartColors.length];
        //       return PieChartSectionData(
        //         value: percentage,
        //         title: '${(percentage * 100).toInt()}%',
        //         color: pieColor,
        //         radius: 50,
        //         titleStyle: const TextStyle(
        //           color: Colors.white,
        //           fontWeight: FontWeight.bold,
        //           fontSize: 16,
        //         ),
        //       );
        //     }).toList();

        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }

    try {
      final response = await http.get(Uri.parse('${baseUrl}graph_eq.php'));
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _totalEqCount = jsonData.fold<int>(
          0,
          (sum, item) => sum + int.parse(item['eq_count'].toString()),
        );
        double totalEqCount = jsonData.fold<double>(
          0,
          (sum, item) => sum + double.parse(item['eq_count']),
        );

        _pieEQSections =
            jsonData
                .where(
                  (item) => [
                    'ครุภัณฑ์สำนักงาน',
                    'ครุภัณฑ์คอมพิวเตอร์',
                  ].contains(item['eq_type']),
                )
                .map((item) {
                  final eqCount = int.parse(item['eq_count']);
                  final percentage = eqCount / totalEqCount * 100;
                  final pieColor =
                      AppColors.eqchartColors[jsonData.indexOf(item) %
                          AppColors.eqchartColors.length];
                  return PieChartSectionData(
                    value: percentage,
                    title: '${eqCount.toInt()}', // Display actual count
                    color: pieColor,
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  );
                })
                .toList();

        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }

    try {
      final response = await http.get(Uri.parse('${baseUrl}graph_mt.php'));
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _totalMtCount = jsonData.fold<int>(
          0,
          (sum, item) => sum + int.parse(item['mt_count'].toString()),
        );
        double totalMtCount = jsonData.fold<double>(
          0,
          (sum, item) => sum + double.parse(item['mt_count']),
        );

        _pieMTSections =
            jsonData
                .where(
                  (item) => [
                    'วัสดุสิ้นเปลือง',
                    'วัสดุถาวร',
                  ].contains(item['mt_type']),
                )
                .map((item) {
                  final mtCount = int.parse(item['mt_count']);
                  final percentage = mtCount / totalMtCount * 100;
                  final pieColor =
                      AppColors.mtchartColors[jsonData.indexOf(item) %
                          AppColors.mtchartColors.length];
                  return PieChartSectionData(
                    value: percentage,
                    title: '${mtCount.toInt()}', // Display actual count
                    color: pieColor,
                    radius: 50,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  );
                })
                .toList();

        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .start, // Or MainAxisAlignment.start if you want spacing at the end
          children: [
            Text(
              'รายงานสรุป',
              style: TextStyle(fontFamily: Fonts.FontBold.fontFamily),
            ),
            if (userRole == 'Admin' || userRole == 'Officer')
              SizedBox(
                width: 160,
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminPage(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.circle,
                          color: Colors.purple[300],
                          size: 16,
                        ),
                        label: Text(
                          'การเบิกวัสดุ',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (userRole == 'Engineer' || userRole == 'Admin')
              Container(
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AdminMaintenance(token: widget.token),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.circle,
                        color: Colors.green[300],
                        size: 16,
                      ),
                      label: Text(
                        'รายการงานซ่อม',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          //Keep this empty, or remove entirely. Important!
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Wrap(
                      alignment:
                          WrapAlignment.start, // จัดตำแหน่ง widget ใน Wrap
                      children: [
                        Container(
                          width: Responsive.isMobile(context) ? 175 : 360,
                          height: Responsive.isMobile(context) ? 85 : 100,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.purple[300],
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutMtReport(),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  Responsive.isMobile(context)
                                      ? 'จำนวนการเบิก\nวัสดุทั้งหมด: $_totalOrderCount'
                                      : 'จำนวนการเบิกวัสดุทั้งหมด:   $_totalOrderCount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16, height: 100),
                        Container(
                          width: Responsive.isMobile(context) ? 175 : 360,
                          height: Responsive.isMobile(context) ? 85 : 100,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MaintenanceReport(
                                          token: widget.token,
                                        ),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  Responsive.isMobile(context)
                                      ? 'จำนวนการแจ้ง\nซ่อมทั้งหมด: $_totalMaintenCount'
                                      : 'จำนวนการแจ้งซ่อมทั้งหมด: $_totalMaintenCount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16, height: 100),
                        Container(
                          width: Responsive.isMobile(context) ? 175 : 360,
                          height: Responsive.isMobile(context) ? 85 : 100,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.orange[300],
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            EquipmentPage(token: widget.token),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  Responsive.isMobile(context)
                                      ? 'จำนวนครุภัณฑ์\nทั้งหมด: $_totalEqCount'
                                      : 'จำนวนครุภัณฑ์ทั้งหมด:   $_totalEqCount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16, height: 100),
                        Container(
                          width: Responsive.isMobile(context) ? 175 : 360,
                          height: Responsive.isMobile(context) ? 85 : 100,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.pink[300],
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            MaterialHome(token: widget.token),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  Responsive.isMobile(context)
                                      ? 'จำนวน\nวัสดุทั้งหมด: $_totalMtCount'
                                      : 'จำนวนวัสดุทั้งหมด:   $_totalMtCount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                        ) {
                          // if (constraints.maxWidth < 600) {
                          if (Responsive.isMobile(context)) {
                            // If screen width is less than 600, arrange charts vertically
                            return Column(
                              children: [
                                buildBarChart(
                                  title: 'จำนวนการเบิกวัสดุ',
                                  barGroups: _barGroups,
                                  months: _months,
                                  // years: _years,
                                ),
                                SizedBox(height: 16),
                                buildPieChart(
                                  title: 'จำนวนการเบิกวัสดุ (ร้อยละ)',
                                  pieSections: _pieSections,
                                  months: _months,
                                ),
                                SizedBox(height: 16),
                                buildEQPieChart(
                                  title: 'จำนวนครุภัณฑ์',
                                  pieEQSections: _pieEQSections,
                                  type:
                                      Responsive.isMobile(context)
                                          ? 'สำนักงาน'
                                          : 'ครุภัณฑ์สำนักงาน',
                                  type2:
                                      Responsive.isMobile(context)
                                          ? 'คอมพิวเตอร์'
                                          : 'ครุภัณฑ์คอมพิวเตอร์',
                                ),
                                SizedBox(height: 16),
                                buildEQPieChart(
                                  title: 'จำนวนวัสดุ',
                                  type: 'วัสดุสิ้นเปลือง',
                                  type2: 'วัสดุถาวร',
                                  pieEQSections: _pieMTSections,
                                ),
                              ],
                            );
                          } else {
                            // Otherwise, arrange charts horizontally
                            return Column(
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 16.0, // ช่องว่างแนวนอนระหว่างกราฟ
                                  runSpacing:
                                      16.0, // ช่องว่างแนวตั้งระหว่างบรรทัด (หากกราฟล้น)
                                  children: [
                                    SizedBox(
                                      height: 360,
                                      width: constraints.maxWidth / 2 - 16,
                                      child: buildBarChart(
                                        title: 'จำนวนการเบิกวัสดุ',
                                        barGroups: _barGroups,
                                        months: _months,
                                        // years: _years,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 360,
                                      width: constraints.maxWidth / 2 - 16,
                                      child: buildPieChart(
                                        title: 'จำนวนการเบิกวัสดุ (ร้อยละ)',
                                        pieSections: _pieSections,
                                        months: _months,
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth / 2 - 16,
                                      child: buildEQPieChart(
                                        title: 'จำนวนครุภัณฑ์',
                                        pieEQSections: _pieEQSections,
                                        type: 'ครุภัณฑ์สำนักงาน',
                                        type2: 'ครุภัณฑ์คอมพิวเตอร์',
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth / 2 - 16,
                                      child: buildMTPieChart(
                                        title: 'จำนวนวัสดุ',
                                        type: 'วัสดุสิ้นเปลือง',
                                        type2: 'วัสดุถาวร',
                                        pieMTSections: _pieMTSections,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
