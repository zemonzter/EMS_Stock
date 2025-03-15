import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditMaintenanceStatus extends StatefulWidget {
  final Map<String, dynamic> maintenanceStatus;

  const EditMaintenanceStatus({super.key, required this.maintenanceStatus});

  @override
  State<EditMaintenanceStatus> createState() => _EditMaintenanceStatusState();
}

class _EditMaintenanceStatusState extends State<EditMaintenanceStatus> {
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _statusController = TextEditingController(
      text: widget.maintenanceStatus['mainten_status'],
    );
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _deleteMaintenanceStatus(String statusId) async {
    String uri = "${baseUrl}delete_maintenance_status.php";
    try {
      final response = await http
          .post(Uri.parse(uri), body: {'status_id': statusId})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        if (decodedResponse is Map && decodedResponse['success'] == 'true') {
          Navigator.pop(context, null);
        } else {
          // _showError("Failed to delete status: ${decodedResponse['message']}");
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      // _showError("Failed to delete status: $e");
      Navigator.pop(context, null);
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
          Navigator.pop(context, newStatus);
        } else {
          // _showError("Failed to update status: ${decodedResponse['message']}");
          Navigator.pop(context, newStatus);
        }
      } else {
        _showError("HTTP request failed: ${response.statusCode}");
      }
    } catch (e) {
      // _showError("Failed to update status: $e");
      Navigator.pop(context, newStatus);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "แก้ไขสถานะการแจ้งซ่อม",
          style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
        ),
      ),
      body: Center(
        child: SizedBox(
          width:
              Responsive.isDesktop(context)
                  ? 1000
                  : Responsive.isTablet(context)
                  ? 700
                  : double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "สถานะการแจ้งซ่อม",
                  style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _statusController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "สถานะการแจ้งซ่อม",
                    labelStyle: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String newStatus = _statusController.text;
                        _updateMaintenanceStatus(
                          widget.maintenanceStatus['status_id'].toString(),
                          newStatus,
                        );
                      },
                      child: Text(
                        "แก้ไข",
                        style: TextStyle(
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'ยืนยันการลบสถานะการแจ้งซ่อม',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              content: Text(
                                'คุณแน่ใจหรือไม่ว่าต้องการลบสถานะการแจ้งซ่อมนี้?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    _deleteMaintenanceStatus(
                                      widget.maintenanceStatus['status_id'],
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'ยืนยัน',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                      ),
                      child: Text(
                        'ลบ',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
