import 'dart:convert';
// import 'package:ems_condb/user_page/settings/Setting_eq/insert_eq_type.dart';
// import 'package:ems_condb/user_page/settings/setting_eq/edit_eq_type.dart';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/user_page/settings/setting_mt/edit_unit.dart';
import 'package:ems_condb/user_page/settings/setting_mt/insert_unit.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingUnit extends StatefulWidget {
  const SettingUnit({super.key});

  @override
  State<SettingUnit> createState() => _SettingUnitState();
}

class _SettingUnitState extends State<SettingUnit> {
  List types = [];
  bool _isLoading = true;

  Future<void> getType() async {
    setState(() {
      _isLoading = true;
    });
    String uri = "${baseUrl}view_unit.php";
    try {
      // final response = await http
      //     .get(Uri.parse(uri))
      //     .timeout(const Duration(seconds: 10)); // เพิ่ม timeout
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          setState(() {
            types = List<Map<String, dynamic>>.from(
              decodedResponse,
            ); // แปลงเป็น List<Map>
            _isLoading = false;
          });
        } else if (decodedResponse is Map &&
            decodedResponse['success'] == 'false') {
          _showError("Error fetching types: ${decodedResponse['message']}");
        } else {
          _showError("Unexpected response format.");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Failed to fetch types: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUnitName(String unitId, String newName) async {
    String uri = "${baseUrl}update_unit.php";
    try {
      final response = await http
          .post(Uri.parse(uri), body: {'unit_id': unitId, 'unit_name': newName})
          .timeout(const Duration(seconds: 10)); // เพิ่ม timeout

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          getType();
        } else {
          _showError("Failed to update name: ${decodedResponse['message']}");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      //_showError("Failed to update name: $e");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    print(message);
  }

  @override
  void initState() {
    super.initState();
    getType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "จัดการหน่วยนับ",
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                // MaterialPageRoute(builder: (context) => const InsertmtType()),
                MaterialPageRoute(builder: (context) => const InsertUnit()),
              );
              if (result != null && result == true) {
                getType(); // รีเฟรชข้อมูล
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'เพิ่มหน่วยนับ',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : types.isNotEmpty
              ? Center(
                child: SizedBox(
                  width:
                      Responsive.isDesktop(context)
                          ? 1000
                          : Responsive.isTablet(context)
                          ? 700
                          : double.infinity,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final type = types[index];
                      final String name = type['unit_name'] ?? '';

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditUnit(unit: type),
                              ),
                            );

                            if (result != null) {
                              if (result is String) {
                                String newName = result;
                                setState(() {
                                  type['unit_name'] = newName;
                                });
                                _updateUnitName(
                                  type['unit_id'].toString(),
                                  newName,
                                );
                              }
                            } else {
                              getType(); //Reload data after delete.
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
