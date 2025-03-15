import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mainten_page/mainten_form.dart';
import 'show_mainten_detail.dart';
import 'package:http/http.dart' as http;

class MaintenanceReport extends StatefulWidget {
  final String? token;
  const MaintenanceReport({super.key, this.token});

  @override
  State<MaintenanceReport> createState() => _MaintenanceReportState();
}

class _MaintenanceReportState extends State<MaintenanceReport> {
  List bgdata = [];
  String? selectedStatus; // Holds the selected status filter.
  String? userId; // To store the user's ID.
  String? selectedFilter = "all"; // Default filter: show all
  List<Map<String, dynamic>> statusOptions = []; //status dropdown

  @override
  void initState() {
    super.initState();
    _fetchStatusOptions();
    _fetchUserData().then((_) {
      // Fetch data after getting user data.
      getrecord();
    });
  }

  Future<void> _fetchStatusOptions() async {
    final url = Uri.parse('${baseUrl}view_mainten_status.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        if (mounted) {
          setState(() {
            statusOptions = List<Map<String, dynamic>>.from(decodedData);
            // Add an "All" option at the beginning.  Important for filtering.
            statusOptions.insert(0, {
              "status_id": null,
              "mainten_status": "ทั้งหมด",
            });
          });
        }
      } else {
        print('Failed to fetch status options: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching status options: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _getUserData();
      if (mounted) {
        setState(() {
          userId =
              userData['name']
                  as String?; // Get and store the user ID.  Important!
        });
      }
    } catch (e) {
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

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_mainten.php";
    try {
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        setState(() {
          bgdata = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _refreshData() async {
    await getrecord();
  }

  List<Map<String, dynamic>> _filterData() {
    List<Map<String, dynamic>> filteredData = List.from(bgdata);

    // Filter by selected status.  Use 'null' to represent "All".
    if (selectedStatus != null && selectedStatus != "ทั้งหมด") {
      filteredData =
          filteredData
              .where((item) => item['mainten_status'] == selectedStatus)
              .toList();
    }

    // Apply user-specific filter *after* status filter
    if (selectedFilter == "my_requests" && userId != null) {
      filteredData =
          filteredData.where((item) => item['user_mainten'] == userId).toList();
    }

    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int maxLength = (screenWidth * 0.1).toInt();
    final int detailMaxLength = (screenWidth * 0.3).toInt();

    // Filter the data based on dropdown selection
    final List<Map<String, dynamic>> displayedData = _filterData();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "แจ้งซ่อม",
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.mali().fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          //   IconButton(
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return AlertDialog(
          //             title: Text(
          //               'เลือกเงื่อนไข',
          //               style: TextStyle(
          //                 fontFamily: GoogleFonts.mali().fontFamily,
          //               ),
          //             ),
          //             content: StatefulBuilder(
          //               builder: (context, setState) {
          //                 return Column(
          //                   mainAxisSize: MainAxisSize.min,
          //                   children: [
          //                     DropdownButton<String>(
          //                       value: selectedFilter,
          //                       onChanged: (String? newValue) {
          //                         setState(() {
          //                           selectedFilter = newValue!;
          //                           // Reset status filter when changing user filter
          //                           selectedStatus = null;
          //                         });
          //                       },
          //                       items: [
          //                         DropdownMenuItem(
          //                           value: "all",
          //                           child: Text(
          //                             "ทั้งหมด",
          //                             style: TextStyle(
          //                               fontFamily: GoogleFonts.mali().fontFamily,
          //                             ),
          //                           ),
          //                         ),
          //                         DropdownMenuItem(
          //                           value: "my_requests",
          //                           child: Text(
          //                             "ข้อมูลการสั่งซ่อมของฉัน",
          //                             style: TextStyle(
          //                               fontFamily: GoogleFonts.mali().fontFamily,
          //                             ),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                     // if (selectedFilter != "my_requests")
          //                     DropdownButton<String>(
          //                       value:
          //                           selectedStatus ??
          //                           (statusOptions.isNotEmpty
          //                               ? statusOptions[0]['mainten_status']
          //                               : null),
          //                       hint: Text(
          //                         "เลือกสถานะ",
          //                         style: TextStyle(
          //                           fontFamily: GoogleFonts.mali().fontFamily,
          //                         ),
          //                       ),
          //                       onChanged: (String? newValue) {
          //                         setState(() {
          //                           selectedStatus = newValue;
          //                         });
          //                       },
          //                       items:
          //                           statusOptions.map<DropdownMenuItem<String>>((
          //                             Map<String, dynamic> status,
          //                           ) {
          //                             return DropdownMenuItem<String>(
          //                               value: status['mainten_status'],
          //                               child: Text(
          //                                 status['mainten_status'],
          //                                 style: TextStyle(
          //                                   fontFamily:
          //                                       GoogleFonts.mali().fontFamily,
          //                                 ),
          //                               ),
          //                             );
          //                           }).toList(),
          //                     ),
          //                   ],
          //                 );
          //               },
          //             ),
          //             actions: [
          //               TextButton(
          //                 onPressed: () {
          //                   _filterData();

          //                   Navigator.pop(context);
          //                 },
          //                 child: Text(
          //                   'ตกลง',
          //                   style: TextStyle(
          //                     fontFamily: GoogleFonts.mali().fontFamily,
          //                   ),
          //                 ),
          //               ),
          //               TextButton(
          //                 onPressed: () {
          //                   Navigator.pop(context);
          //                 },
          //                 child: Text(
          //                   'ยกเลิก',
          //                   style: TextStyle(
          //                     fontFamily: GoogleFonts.mali().fontFamily,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           );
          //         },
          //       );
          //     },
          //     icon: Icon(Icons.filter_list),
          //   ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaintenanceForm(token: widget.token),
                ),
              );

              if (result == true) {
                await _refreshData();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width:
              Responsive.isMobile(context)
                  ? double.infinity
                  : Responsive.isTablet(context)
                  ? 800
                  : 1000,
          child: Column(
            children: [
              // Filter Dropdowns
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // User Filter Dropdown
                    DropdownButton<String>(
                      value: selectedFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFilter = newValue!;
                          // Reset status filter when changing user filter
                          selectedStatus = null;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: "all",
                          child: Text(
                            "ทั้งหมด",
                            style: TextStyle(
                              fontFamily: GoogleFonts.mali().fontFamily,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "my_requests",
                          child: Text(
                            "ข้อมูลการสั่งซ่อมของฉัน",
                            style: TextStyle(
                              fontFamily: GoogleFonts.mali().fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Status Filter Dropdown (only if not showing user's requests)
                    // if (selectedFilter != "my_requests")
                    DropdownButton<String>(
                      value:
                          selectedStatus ??
                          (statusOptions.isNotEmpty
                              ? statusOptions[0]['mainten_status']
                              : null), // Default to "ทั้งหมด"
                      hint: Text(
                        "เลือกสถานะ",
                        style: TextStyle(
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus =
                              newValue; // Directly use the selected value
                        });
                      },
                      items:
                          statusOptions.map<DropdownMenuItem<String>>((
                            Map<String, dynamic> status,
                          ) {
                            return DropdownMenuItem<String>(
                              value:
                                  status['mainten_status'], // Use mainten_status as the value
                              child: Text(
                                status['mainten_status'],
                                style: TextStyle(
                                  fontFamily: GoogleFonts.mali().fontFamily,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              // Data List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child:
                      displayedData.isEmpty
                          ? Center(
                            child: Text(
                              'ไม่มีข้อมูล',
                              style: TextStyle(
                                fontFamily: GoogleFonts.mali().fontFamily,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: displayedData.length,
                            itemBuilder: (context, index) {
                              final request = displayedData[index];
                              String userMaintenText = request["user_mainten"];
                              String detailText = request["mainten_detail"];

                              String displayedUserText =
                                  userMaintenText.length > maxLength
                                      ? "${userMaintenText.substring(0, maxLength)}..."
                                      : "ผู้แจ้ง: $userMaintenText";

                              String displayedDetailText =
                                  detailText.length > detailMaxLength
                                      ? "${detailText.substring(0, detailMaxLength)}..."
                                      : detailText;

                              return SafeArea(
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ShowMaintenDetail(
                                                  id: request["mainten_id"],
                                                  name: request["eq_name"],
                                                  date: request["mainten_date"],
                                                  detail:
                                                      request["mainten_detail"],
                                                  user: request["user_mainten"],
                                                  status:
                                                      request["mainten_status"],
                                                  img:
                                                      (baseUrl +
                                                              request["mainten_img"] ??
                                                          ''),
                                                  hn: request["eq_id"],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "เลขแจ้งซ่อม: " +
                                                            request["mainten_id"],
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              GoogleFonts.mali()
                                                                  .fontFamily,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        "HN: " +
                                                            request["eq_id"],
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              GoogleFonts.mali()
                                                                  .fontFamily,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        "รายละเอียด: $displayedDetailText",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily:
                                                              GoogleFonts.mali()
                                                                  .fontFamily,
                                                        ),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    displayedUserText,
                                                    style: TextStyle(
                                                      fontSize:
                                                          Responsive.isMobile(
                                                                context,
                                                              )
                                                              ? 14
                                                              : Responsive.isTablet(
                                                                context,
                                                              )
                                                              ? 16
                                                              : 18,
                                                      fontFamily:
                                                          GoogleFonts.mali()
                                                              .fontFamily,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Flexible(
                                                  child: SizedBox(
                                                    width:
                                                        Responsive.isMobile(
                                                              context,
                                                            )
                                                            ? 95
                                                            : Responsive.isTablet(
                                                              context,
                                                            )
                                                            ? 200
                                                            : 250,
                                                    child: Text(
                                                      request["mainten_date"],
                                                      style: TextStyle(
                                                        fontSize:
                                                            Responsive.isMobile(
                                                                  context,
                                                                )
                                                                ? 14
                                                                : Responsive.isTablet(
                                                                  context,
                                                                )
                                                                ? 16
                                                                : 18,
                                                        fontFamily:
                                                            GoogleFonts.mali()
                                                                .fontFamily,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.fade,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    "สถานะ: ${request["mainten_status"]}",
                                                    style: TextStyle(
                                                      fontSize:
                                                          Responsive.isMobile(
                                                                context,
                                                              )
                                                              ? 14
                                                              : Responsive.isTablet(
                                                                context,
                                                              )
                                                              ? 16
                                                              : 18,
                                                      fontFamily:
                                                          GoogleFonts.mali()
                                                              .fontFamily,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
