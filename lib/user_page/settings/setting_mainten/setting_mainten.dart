import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/user_page/settings/setting_mainten/edit_mainten_status.dart';
import 'package:ems_condb/user_page/settings/setting_mainten/insert_status.dart';
import 'package:ems_condb/user_page/settings/setting_mt/insert_unit.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingMaintenanceStatus extends StatefulWidget {
  const SettingMaintenanceStatus({super.key});

  @override
  State<SettingMaintenanceStatus> createState() =>
      _SettingMaintenanceStatusState();
}

class _SettingMaintenanceStatusState extends State<SettingMaintenanceStatus> {
  List statuses = [];
  bool _isLoading = true;

  Future<void> getMaintenanceStatuses() async {
    setState(() {
      _isLoading = true;
    });
    String uri = "${baseUrl}view_maintenance_status.php";
    try {
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          setState(() {
            statuses = List<Map<String, dynamic>>.from(decodedResponse);
            _isLoading = false;
          });
        } else if (decodedResponse is Map &&
            decodedResponse['success'] == 'false') {
          _showError("Error fetching statuses: ${decodedResponse['message']}");
        } else {
          _showError("Unexpected response format.");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Failed to fetch statuses: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateMaintenanceStatus(
    String statusId,
    String newStatus,
  ) async {
    String uri = "${baseUrl}update_maintenance_status.php";
    try {
      final response = await http
          .post(
            Uri.parse(uri),
            body: {'status_id': statusId, 'mainten_status': newStatus},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          getMaintenanceStatuses();
        } else {
          _showError("Failed to update status: ${decodedResponse['message']}");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      //_showError("Failed to update status: $e");
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
    getMaintenanceStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "จัดการสถานะการแจ้งซ่อม",
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
                MaterialPageRoute(
                  builder: (context) => const InsertMaintenanceStatus(),
                ), // หรือ InsertMaintenanceStatus
              );
              if (result != null && result == true) {
                getMaintenanceStatuses(); // รีเฟรชข้อมูล
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'เพิ่มสถานะการแจ้งซ่อม',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : statuses.isNotEmpty
              ? Center(
                child: SizedBox(
                  width:
                      Responsive.isDesktop(context)
                          ? 1000
                          : Responsive.isTablet(context)
                          ? 700
                          : double.infinity,
                  child: ListView.builder(
                    itemCount: statuses.length,
                    itemBuilder: (context, index) {
                      final status = statuses[index];
                      final String name = status['mainten_status'] ?? '';

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditMaintenanceStatus(
                                      maintenanceStatus: status,
                                    ),
                              ),
                            );

                            if (result != null) {
                              if (result is String) {
                                String newName = result;
                                setState(() {
                                  status['mainten_status'] = newName;
                                });
                                _updateMaintenanceStatus(
                                  status['status_id'].toString(),
                                  newName,
                                );
                              }
                            } else {
                              getMaintenanceStatuses(); //Reload data after delete.
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                              textAlign: TextAlign.center,
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
