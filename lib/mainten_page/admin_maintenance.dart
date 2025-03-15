import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminMaintenance extends StatefulWidget {
  final String? token;
  const AdminMaintenance({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminMaintenance> createState() => _AdminMaintenanceState();
}

class _AdminMaintenanceState extends State<AdminMaintenance> {
  List<Map<String, dynamic>> requests = [];
  Map<String, String?> selectedStatuses =
      {}; // Use String? to allow for null values
  String? userName;
  List<Map<String, dynamic>> statusOptions = []; // List to store status options

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _fetchUserData();
    _fetchStatusOptions(); // Fetch status options
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _getUserData();
      if (mounted) {
        setState(() {
          userName = userData['name'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = "Error";
        });
      }
      print("Error fetching user data: $e");
    }
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(
      Uri.parse('https://api.rmutsv.ac.th/elogin/token/${widget.token}'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
        'Failed to retrieve user data. Status code: ${response.statusCode}',
      );
    }
  }

  Future<void> _fetchStatusOptions() async {
    final url = Uri.parse(
      '${baseUrl}view_mainten_status.php',
    ); // Your API endpoint
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        if (mounted) {
          setState(() {
            // Store the entire map (status_id and mainten_status)
            statusOptions = List<Map<String, dynamic>>.from(decodedData);
          });
        }
      } else {
        print('Failed to fetch status options: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching status options: $e');
    }
  }

  Future<void> _fetchRequests() async {
    final url = Uri.parse('${baseUrl}view_mainten.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> allRequests =
            List<Map<String, dynamic>>.from(
              jsonDecode(utf8.decode(response.bodyBytes)),
            );

        if (mounted) {
          setState(() {
            requests =
                allRequests
                    .where(
                      (request) =>
                          request['mainten_status'] != 'ซ่อมไม่สำเร็จ' &&
                          request['mainten_status'] != 'ซ่อมสำเร็จ',
                    ) // Keep only "active" requests
                    .toList();

            // Initialize selectedStatuses map, handling possible null status_id
            for (var request in requests) {
              selectedStatuses[request['mainten_id']] =
                  request['mainten_status']; // Use mainten_status now
            }
          });
        }
      } else {
        print('Failed to fetch requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  // Updated _updateStatus to use status_id
  Future<void> _updateStatus(String requestId, String? newStatus) async {
    if (newStatus == null) {
      print("Cannot update status with a null value");
      return; // Or handle appropriately
    }

    // Find the status_id that corresponds to the selected mainten_status
    String? statusId;
    for (var statusOption in statusOptions) {
      if (statusOption['mainten_status'] == newStatus) {
        statusId = statusOption['mainten_status'];
        break;
      }
    }

    if (statusId == null) {
      print("Could not find status_id for: $newStatus");
      return; // Or show an error
    }

    final url = Uri.parse('${baseUrl}update_mainten_status.php');
    try {
      final response = await http.post(
        url,
        body: {
          'mainten_id': requestId,
          'mainten_status': newStatus, // Use status_id
          'operator': userName ?? '',
        },
      );

      if (response.statusCode == 200) {
        _fetchRequests(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'อัพเดทสถานะเรียบร้อย',
              style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
            ),
          ),
        );
      } else {
        print('Failed to update status: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update status',
              style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating status',
            style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'รายการงานซ่อม',
          style: TextStyle(
            fontFamily: GoogleFonts.mali().fontFamily,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          requests.isEmpty
              ? Center(
                child: Text(
                  'ไม่มีคำขอใหม่',
                  style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
                ),
              )
              : ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'เลขแจ้งซ่อม: ${request['mainten_id']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.mali().fontFamily,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HN: ${request['eq_id']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                                Text(
                                  'ชื่อครุภัณฑ์: ${request['eq_name']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                                Text(
                                  'รายละเอียด: ${request['mainten_detail']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                                Text(
                                  'User: ${request['user_mainten']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                                Text(
                                  'Date: ${request['mainten_date']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: GoogleFonts.mali().fontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DropdownButton<String>(
                                value:
                                    selectedStatuses[request['mainten_id']] ??
                                    'แจ้งซ่อม', // Handle empty statusOptions

                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedStatuses[request['mainten_id']] =
                                          newValue;
                                    });
                                    _updateStatus(
                                      request['mainten_id'],
                                      newValue,
                                    ); // Pass mainten_status
                                  }
                                },
                                items:
                                    statusOptions
                                        .map<DropdownMenuItem<String>>(
                                          (
                                            Map<String, dynamic> status,
                                          ) => DropdownMenuItem<String>(
                                            value:
                                                status['mainten_status'], // Use mainten_status here
                                            child: Text(
                                              status['mainten_status'], // Display mainten_status
                                              style: TextStyle(
                                                fontFamily:
                                                    GoogleFonts.mali()
                                                        .fontFamily,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
