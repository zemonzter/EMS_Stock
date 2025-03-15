import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th', null).then((_) {
      // Initialize here
      _fetchRequests();
    });
  }

  Future<void> _fetchRequests() async {
    final url = Uri.parse('${baseUrl}get_requests.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> allRequests =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // Filter and sort requests
        setState(() {
          requests =
              allRequests
                  .where((request) => request['status'] == 'รออนุมัติ')
                  .toList()
                ..sort(
                  (a, b) => int.parse(
                    b['request_id'],
                  ).compareTo(int.parse(a['request_id'])),
                ); // Sort by request_id descending
        });
      } else {
        print('Failed to fetch requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  Future<void> _approveRequest(int requestId) async {
    final url = Uri.parse('${baseUrl}approve_checkout.php');
    try {
      final response = await http.post(
        url,
        body: {'request_id': requestId.toString(), 'action': 'อนุมัติคำขอ'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == "true") {
          _fetchRequests(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('อนุมัติคำขอเรียบร้อยแล้ว')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to approve request: ${data['message']}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('อนุมัติคำขอเรียบร้อยแล้ว')));
      _fetchRequests();
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    final url = Uri.parse('${baseUrl}approve_checkout.php');
    try {
      final response = await http.post(
        url,
        body: {'request_id': requestId.toString(), 'action': 'ปฏิเสธคำขอ'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == "true") {
          _fetchRequests(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('คำขอถูกปฏิเสธเรียบร้อยแล้ว')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject request: ${data['message']}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to server')),
        );
      }
    } catch (e) {
      print('Error rejecting request: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    final items = jsonDecode(request['items']);
    DateTime requestDate = DateTime.parse(request['request_date']);
    int buddhistYear = requestDate.year + 543;
    String formattedDate = DateFormat('d MMMM', 'th').format(requestDate);
    String displayDate = '$formattedDate $buddhistYear';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'รายละเอียดคำขอ ${request['request_id']}',
            style: TextStyle(
              fontFamily: Fonts.FontBold.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width *
                0.5, // กำหนดความกว้าง 50% ของหน้าจอ
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ผู้เบิก: ${request['username']}',
                    style: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'วันที่: $displayDate',
                    style: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'สถานะ: ${request['status']}',
                    style: TextStyle(
                      fontFamily: Fonts.Fontnormal.fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'รายการวัสดุ:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: Fonts.Fontnormal.fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.grey[700]!, width: 1),
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(3),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.blue[300]),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TableCell(
                              child: Center(
                                child: Text(
                                  'ลำดับ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'รายการ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'จำนวน',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'หน่วย',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var item in items)
                        TableRow(
                          children: [
                            TableCell(
                              child: Center(
                                child: Text(
                                  '${items.indexOf(item) + 1}',
                                  style: TextStyle(
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  '${item['mt_name']}',
                                  style: TextStyle(
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text(
                                  '${item['quantity']}',
                                  style: TextStyle(
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text(
                                  '${item['unit_id']}',
                                  style: TextStyle(
                                    fontFamily: Fonts.Fontnormal.fontFamily,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  String formatRequestDate(dynamic dateString) {
    if (dateString == null) {
      return '';
    }

    try {
      DateTime parsedDate;
      if (dateString is DateTime) {
        parsedDate = dateString;
      } else {
        parsedDate = DateTime.parse(dateString);
      }

      // Format with Buddhist Era (B.E.) year
      final buddhistYear = parsedDate.year + 543;
      return DateFormat('d MMMM ', 'th').format(parsedDate) +
          buddhistYear.toString();
    } catch (e) {
      return 'ไม่มีข้อมูลวันที่';
    }
  }

  Widget buildRequestList(List<Map<String, dynamic>> requests) {
    return SingleChildScrollView(
      // เพิ่ม SingleChildScrollView เพื่อให้เลื่อนตารางได้
      child: Center(
        child: SizedBox(
          // width: MediaQuery.of(context).size.width * 0.9,
          width: double.infinity,
          child: Table(
            border: TableBorder.all(color: Colors.grey[300]!, width: 1),
            columnWidths: {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(Responsive.isMobile(context) ? 1 : 3),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(2),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Center(
                      child: Text(
                        'ลำดับ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                          fontSize: Responsive.isMobile(context) ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Center(
                      child: Text(
                        'ผู้เบิก',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                          fontSize: Responsive.isMobile(context) ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Center(
                      child: Text(
                        'วันที่',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                          fontSize: Responsive.isMobile(context) ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                  if (Responsive.isDesktop(context))
                    TableCell(
                      child: Center(
                        child: Text(
                          'สถานะ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                            fontSize: Responsive.isMobile(context) ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                  TableCell(
                    child: Center(
                      child: Text(
                        'รายละเอียด',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                          fontSize: Responsive.isMobile(context) ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Center(
                      child: Text(
                        'อนุมัติ/ปฏิเสธ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                          fontSize: Responsive.isMobile(context) ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ...requests.map((request) {
                DateTime requestDate = DateTime.parse(request['request_date']);
                int buddhistYear = requestDate.year + 543;
                String formattedDate = DateFormat(
                  'd MMMM',
                  'th',
                ).format(requestDate);
                String formattedDateMobile = DateFormat(
                  'd MMM',
                  'th',
                ).format(requestDate);
                String displayDate = '$formattedDate $buddhistYear';
                String displayDateMobile = '$formattedDateMobile $buddhistYear';
                if (Responsive.isMobile(context)) {
                  displayDateMobile =
                      '$formattedDateMobile ${buddhistYear.toString().substring(2)}';
                } else {
                  displayDate = '$formattedDate $buddhistYear';
                }

                return TableRow(
                  children: [
                    TableCell(
                      child: Center(
                        child: Text(
                          '${request['request_id']}',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                            fontSize: Responsive.isMobile(context) ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          '${request['username']}',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                            fontSize: Responsive.isMobile(context) ? 12 : 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          Responsive.isMobile(context)
                              ? displayDateMobile
                              : displayDate,
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                            fontSize: Responsive.isMobile(context) ? 12 : 14,
                          ),
                        ),
                      ),
                    ),
                    if (Responsive.isDesktop(context))
                      TableCell(
                        child: Center(
                          child: Text(
                            '${request['status']}',
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                              fontSize: Responsive.isMobile(context) ? 12 : 14,
                            ),
                          ),
                        ),
                      ),

                    TableCell(
                      child: Center(
                        child: Tooltip(
                          message: 'รายละเอียด', // ข้อความ tooltip
                          child: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showRequestDetails(request),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child:
                            Responsive.isMobile(context)
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Tooltip(
                                      // เพิ่ม Tooltip
                                      message: 'อนุมัติ', // ข้อความ tooltip
                                      child: IconButton(
                                        onPressed:
                                            () => _approveRequest(
                                              int.parse(request['request_id']),
                                            ),
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    Tooltip(
                                      // เพิ่ม Tooltip
                                      message: 'ปฏิเสธ', // ข้อความ tooltip
                                      child: IconButton(
                                        onPressed:
                                            () => _rejectRequest(
                                              int.parse(request['request_id']),
                                            ),
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed:
                                          () => _approveRequest(
                                            int.parse(request['request_id']),
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text(
                                        'อนุมัติ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed:
                                          () => _rejectRequest(
                                            int.parse(request['request_id']),
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        'ปฏิเสธ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สถานะการเบิกวัสดุ',
          style: TextStyle(
            fontFamily: Fonts.Fontnormal.fontFamily,
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
              // : Column(
              //   children: [
              //     Expanded(
              //       child: LayoutBuilder(
              //         builder: (context, constraints) {
              //           return SingleChildScrollView(
              //             scrollDirection: Axis.vertical,
              //             child: SingleChildScrollView(
              //               scrollDirection: Axis.horizontal,
              //               child: ConstrainedBox(
              //                 constraints: BoxConstraints(
              //                   // minWidth: constraints.minWidth,
              //                   // maxWidth: constraints.maxWidth,
              //                 ),
              //                 child: SizedBox(
              //                   width: constraints.maxWidth,
              //                   child: DataTable(
              //                     border: TableBorder.all(
              //                       color: Colors.grey[300]!, // สีเส้นขอบ
              //                       width: 1, // ความหนาของเส้นขอบ
              //                     ),
              //                     dividerThickness: 1,
              //                     headingRowColor: MaterialStateProperty.all(
              //                       Colors.blue[100],
              //                     ),
              //                     columns: const [
              //                       DataColumn(
              //                         columnWidth: FixedColumnWidth(15),
              //                         label: Text(
              //                           'หมายเลขคำขอ',
              //                           textAlign: TextAlign.center,
              //                         ),
              //                       ),
              //                       DataColumn(label: Text('ผู้เบิก')),
              //                       DataColumn(label: Text('วันที่')),
              //                       DataColumn(label: Text('สถานะ')),
              //                       DataColumn(label: Text('รายละเอียด')),
              //                       DataColumn(label: Text('อนุมัติ/ปฏิเสธ')),
              //                     ],
              //                     rows:
              //                         requests.map((request) {
              //                           final buddhistYear =
              //                               DateTime.parse(
              //                                 request['request_date'],
              //                               ).year +
              //                               543;
              //                           final formattedDate =
              //                               "${DateFormat('dd MMM', 'th').format(DateTime.parse(request['request_date']))} $buddhistYear";
              //                           return DataRow(
              //                             cells: [
              //                               DataCell(
              //                                 Text(request['request_id']),
              //                               ),
              //                               DataCell(Text(request['username'])),
              //                               DataCell(Text(formattedDate)),
              //                               DataCell(Text(request['status'])),
              //                               DataCell(
              //                                 IconButton(
              //                                   icon: const Icon(
              //                                     Icons.info_outline,
              //                                   ),
              //                                   onPressed:
              //                                       () => _showRequestDetails(
              //                                         request,
              //                                       ),
              //                                 ),
              //                               ),
              //                               DataCell(
              //                                 Row(
              //                                   children: [
              //                                     ElevatedButton(
              //                                       onPressed:
              //                                           () => _approveRequest(
              //                                             int.parse(
              //                                               request['request_id'],
              //                                             ),
              //                                           ),
              //                                       style:
              //                                           ElevatedButton.styleFrom(
              //                                             backgroundColor:
              //                                                 Colors.green,
              //                                           ),
              //                                       child: const Text(
              //                                         'อนุมัติ',
              //                                         style: TextStyle(
              //                                           color: Colors.white,
              //                                         ),
              //                                       ),
              //                                     ),
              //                                     const SizedBox(width: 8),
              //                                     ElevatedButton(
              //                                       onPressed:
              //                                           () => _rejectRequest(
              //                                             int.parse(
              //                                               request['request_id'],
              //                                             ),
              //                                           ),
              //                                       style:
              //                                           ElevatedButton.styleFrom(
              //                                             backgroundColor:
              //                                                 Colors.red,
              //                                           ),
              //                                       child: const Text(
              //                                         'ปฏิเสธ',
              //                                         style: TextStyle(
              //                                           color: Colors.white,
              //                                         ),
              //                                       ),
              //                                     ),
              //                                   ],
              //                                 ),
              //                               ),
              //                             ],
              //                           );
              //                         }).toList(),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: buildRequestList(
                        requests,
                      ), // เรียกใช้ buildRequestList ที่แก้ไขแล้ว
                    ),
                  ],
                ),
              ),
    );
  }
}
