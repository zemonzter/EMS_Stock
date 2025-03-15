import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/date_symbol_data_local.dart';

class CheckoutMtReport extends StatefulWidget {
  const CheckoutMtReport({super.key});

  @override
  State<CheckoutMtReport> createState() => _CheckoutMtReportState();
}

class _CheckoutMtReportState extends State<CheckoutMtReport> {
  List<Map<String, dynamic>> requests = [];
  List<String> userNames = [];
  String? selectedUserName;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchUserNames();
  }

  Future<void> _fetchUserNames() async {
    String uri = "${baseUrl}view_user.php";
    try {
      var response = await http.get(Uri.parse(uri));
      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);
        setState(() {
          userNames =
              users.map((user) => user['user_name'].toString()).toList();
        });
        _fetchRequests();
      } else {
        print('Failed to fetch user names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user names: $e');
    }
  }

  Future<void> _fetchRequests() async {
    await initializeDateFormatting('th', null);
    final url = Uri.parse('${baseUrl}get_requests.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(response.body);
        List<Map<String, dynamic>> fetchedRequests =
            rawData.map<Map<String, dynamic>>((item) {
              return {
                'request_id': item['request_id'],
                'username': item['username'],
                'request_date': item['request_date'],
                'status': item['status'],
                'items': jsonDecode(item['items']), // Decode items here
              };
            }).toList();

        //Apply Filter
        setState(() {
          requests =
              fetchedRequests.where((item) {
                final date = DateTime.parse(item['request_date']);
                final isUserMatch =
                    selectedUserName == null ||
                    item['username'] == selectedUserName;
                final isDateMatch =
                    (selectedStartDate == null ||
                        date.isAtSameMomentAs(selectedStartDate!) ||
                        date.isAfter(selectedStartDate!)) &&
                    (selectedEndDate == null ||
                        date.isAtSameMomentAs(selectedEndDate!) ||
                        date.isBefore(selectedEndDate!));
                final isStatusMatch =
                    selectedStatus == null || item['status'] == selectedStatus;
                return isUserMatch && isDateMatch && isStatusMatch;
              }).toList();
        });
      } else {
        print('Failed to fetch requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  String formatRequestDate(dynamic dateString, pw.Font font) {
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

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    // Define a Thai font (you might need to load a .ttf file)
    final font = await PdfGoogleFonts.sarabunRegular();
    initializeDateFormatting('th');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                "รายงานการเบิก",
                style: pw.TextStyle(font: font, fontSize: 16),
              ),
            ),
            if (selectedUserName != null)
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "ผู้เบิก: $selectedUserName",
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ),
            // if (selectedStartDate != null)
            //   pw.Container(
            //     alignment: pw.Alignment.centerLeft,
            //     child: pw.Text(
            //       "วันที่เริ่มต้น: ${DateFormat('dd MMM yyy').format(selectedStartDate!)}",
            //       style: pw.TextStyle(font: font, fontSize: 12),
            //     ),
            //   ),
            // if (selectedEndDate != null)
            //   pw.Container(
            //     alignment: pw.Alignment.centerLeft,
            //     child: pw.Text(
            //       "วันที่สิ้นสุด: ${DateFormat('dd MMM yyy').format(selectedEndDate!)}",
            //       style: pw.TextStyle(font: font, fontSize: 12),
            //     ),
            //   ),
            if (selectedStartDate != null)
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "วันที่เริ่มต้น: ${formatRequestDate(selectedStartDate, font)}",
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ),
            if (selectedEndDate != null)
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "วันที่สิ้นสุด: ${formatRequestDate(selectedEndDate, font)}",
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ),
            if (selectedStatus != null)
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "สถานะ: $selectedStatus",
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ),
            pw.SizedBox(
              height: 20,
            ), // Add some spacing between the main table and item details

            ...requests.map((request) {
              // Use spread operator (...)
              // Check if 'items' exists and is a list.  Crucial for handling cases where 'items' might be missing.
              if (request['items'] is List) {
                List<dynamic> itemsList = request['items'];

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Divider(), // Separator between requests
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'หมายเลขคำขอ: ${request['request_id'] ?? ''}',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'วันที่: ${formatRequestDate(request['request_date'], font)}',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        pw.Padding(
                          padding: pw.EdgeInsets.only(top: 8),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              if (selectedUserName == null)
                                pw.Text(
                                  'ผู้เบิก: ${request['username'] ?? ''}',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              if (selectedStatus == null)
                                pw.Text(
                                  'สถานะ: ${request['status']}',
                                  style: pw.TextStyle(
                                    font: font,
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Create a table for the items within this request.
                        pw.Table.fromTextArray(
                          context: context,
                          headerStyle: pw.TextStyle(
                            font: font,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                          cellStyle: pw.TextStyle(font: font, fontSize: 9),
                          headerDecoration: const pw.BoxDecoration(
                            color: PdfColors.grey200,
                          ),
                          headers: [
                            'ลำดับ',
                            'วัสดุ',
                            'จำนวน',
                          ], // Headers for the item table
                          columnWidths: {
                            0: const pw.FixedColumnWidth(
                              20,
                            ), // Adjust as needed
                            1: const pw.FixedColumnWidth(
                              120,
                            ), // Adjust as needed
                            2: const pw.FixedColumnWidth(
                              60,
                            ), // Adjust as needed
                          },
                          cellAlignments: {
                            0: pw.Alignment.center,
                            1: pw.Alignment.centerLeft,
                            2: pw.Alignment.center,
                          },

                          data:
                              itemsList.map<List<String>>((item) {
                                // Explicitly type the map
                                return [
                                  '${itemsList.indexOf(item) + 1}', // Display row number (starting from 1)
                                  item['mt_name'] ??
                                      '', // Handle potential null values
                                  '${item['quantity'] ?? ''} ${item['unit_id'] ?? ''}', // Handle potential null values
                                ];
                              }).toList(),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Handle the case where 'items' is not a list (e.g., it's null or not present).
                return pw.Container(); // Or some other placeholder/error message.
              }
            }).toList(), // Convert the iterable to a list. VERY IMPORTANT
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'รายงานการเบิก',
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'เลือกเงื่อนไข',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    content: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: selectedUserName,
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(
                                    'บุคคลากรทั้งหมด',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                                ...userNames.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.mali().fontFamily,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  selectedUserName = newValue;
                                });
                              },
                              hint: Text(
                                'เลือกผู้ใช้',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButton<String>(
                              value: selectedStatus,
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(
                                    'ทุกสถานะ',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'อนุมัติคำขอ',
                                  child: Text(
                                    'อนุมัติคำขอ',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'รออนุมัติ',
                                  child: Text(
                                    'รออนุมัติ',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'ปฏิเสธคำขอ',
                                  child: Text(
                                    'ปฏิเสธคำขอ',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  selectedStatus = newValue;
                                });
                              },
                              hint: Text(
                                'เลือกสถานะ',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedStartDate = pickedDate;
                                  });
                                }
                              },
                              child: Text(
                                'เลือกวันเริ่มต้น',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (selectedStartDate != null)
                              Text(
                                'วันเริ่มต้น: ${DateFormat('dd MMM yyy').format(selectedStartDate!)}',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedEndDate = pickedDate;
                                  });
                                }
                              },
                              child: Text(
                                'เลือกวันสิ้นสุด',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (selectedEndDate != null)
                              Text(
                                'วันสิ้นสุด: ${DateFormat('dd MMM yyy').format(selectedEndDate!)}',
                                style: TextStyle(
                                  fontFamily: Fonts.Fontnormal.fontFamily,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _fetchRequests();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ตกลง',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: _generatePdf, // Call the PDF generation function
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body:
          requests.isEmpty
              ? Center(
                child: Text(
                  'ไม่มีรายงานการเบิก',
                  style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
                ),
              )
              : selectedUserName == null
              ? _buildAllUsersReport() // Show all users if none selected
              : _buildSingleUserReport(), // Show single user report
    );
  }

  // Display for all users (original behavior)
  Widget _buildAllUsersReport() {
    return Center(
      child: SizedBox(
        width: Responsive.isDesktop(context) ? 1200 : double.infinity,
        child: ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return buildRequestCard(request);
          },
        ),
      ),
    );
  }

  // Display for a single user
  Widget _buildSingleUserReport() {
    // Filter requests for the selected user.
    final userRequests =
        requests.where((req) => req['username'] == selectedUserName).toList();

    //   if (selectedStatus != null && selectedStatus != 'ทั้งหมด') {
    //   requests.where((req) => req['status'] == selectedStatus).toList();
    // }
    // final statusRequests =
    //     userRequests.where((req) => req['status'] == selectedStatus).toList();

    if (userRequests.isEmpty) {
      return Center(
        child: Text(
          'ไม่มีข้อมูลสำหรับผู้ใช้ $selectedUserName',
          style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: Responsive.isDesktop(context) ? 1200 : double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ผู้เบิก: $selectedUserName',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: Fonts.Fontnormal.fontFamily,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: userRequests.length,
                itemBuilder: (context, index) {
                  final request = userRequests[index];
                  return _buildSingleUserRequestCard(request);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build card for ALL request
  Widget buildRequestCard(Map<String, dynamic> request) {
    DateTime requestDate = DateTime.parse(request['request_date']);
    int buddhistYear = requestDate.year + 543;
    String formattedDate = DateFormat('d MMMM', 'th').format(requestDate);
    String displayDate = '$formattedDate $buddhistYear';
    final items = request['items'];

    return SizedBox(
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Row (Request Details) - Moved OUTSIDE the Table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'หมายเลขคำขอ: ${request['request_id'] ?? ''}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: Fonts.Fontnormal.fontFamily,
                      ),
                    ),
                    Text(
                      'วันที่: $displayDate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: Fonts.Fontnormal.fontFamily,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ผู้เบิก: ${request['username'] ?? ''}',
                      style: TextStyle(
                        fontSize: 16,

                        fontFamily: Fonts.Fontnormal.fontFamily,
                      ),
                    ),
                    // Text(
                    //   'สถานะ: ${request['status']}',
                    //   style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Fonts.Fontnormal.fontFamily),
                    // ),
                    Row(
                      children: [
                        Text(
                          'สถานะ: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                        Text(
                          request['status'],
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: Fonts.Fontnormal.fontFamily,
                            color:
                                request['status'] == 'อนุมัติคำขอ'
                                    ? Colors.green[700]
                                    : (request['status'] == 'ปฏิเสธคำขอ'
                                        ? Colors.red
                                        : Colors.orange[500]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Add spacing
                // Items Table
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: IntrinsicColumnWidth(), // Column for the row number
                    1: FlexColumnWidth(3), // Material name
                    2: FlexColumnWidth(1), // Quantity
                    3: FlexColumnWidth(1), // Unit
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Table Header
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Padding(
                          // Header for row number
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'ลำดับ',
                            style: TextStyle(
                              fontFamily: Fonts.FontBold.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'วัสดุ',
                            style: TextStyle(
                              fontFamily: Fonts.FontBold.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'จำนวน',
                            style: TextStyle(
                              fontFamily: Fonts.FontBold.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'หน่วยนับ',
                            style: TextStyle(
                              fontFamily: Fonts.FontBold.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Table Rows (Items)
                    ...items.map<TableRow>((item) {
                      int index = items.indexOf(
                        item,
                      ); // Get the index of the item
                      return TableRow(
                        children: [
                          Padding(
                            // Row number
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${index + 1}', // Display row number (starting from 1)
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item['mt_name'] ?? '',
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${item['quantity'] ?? ''}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                          ),
                          Padding(
                            // Display the unit
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${item['unit_id'] ?? ''}', // Unit from item data
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a simplified card for a single user's request
  Widget _buildSingleUserRequestCard(Map<String, dynamic> request) {
    // final formattedDate = DateFormat(
    //   'dd MMM yyy',
    // ).format(DateTime.parse(request['request_date']));
    DateTime requestDate = DateTime.parse(request['request_date']);
    int buddhistYear = requestDate.year + 543;
    String formattedDate = DateFormat('d MMMM', 'th').format(requestDate);
    String displayDate = '$formattedDate $buddhistYear';
    final items = request['items'];

    return
    // Card(
    //   margin: const EdgeInsets.all(8),
    //   child: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           'วันที่: $formattedDate',
    //           style: TextStyle(
    //             fontSize: 16,
    //             fontFamily: Fonts.Fontnormal.fontFamily,
    //           ),
    //         ),
    //         Text(
    //           'สถานะ: ${request['status']}',
    //           style: TextStyle(
    //             fontSize: 16,
    //             fontFamily: Fonts.Fontnormal.fontFamily,
    //           ),
    //         ),
    //         const SizedBox(height: 8),
    //         ...items.map<Widget>((item) {
    //           return Padding(
    //             padding: const EdgeInsets.only(left: 16),
    //             child: Row(
    //               children: [
    //                 Text(
    //                   'วัสดุ: ${item['mt_name']} ',
    //                   style: TextStyle(
    //                     fontSize: 16,
    //                     fontWeight: FontWeight.bold,
    //                     fontFamily: Fonts.Fontnormal.fontFamily,
    //                   ),
    //                   maxLines: 1,
    //                   overflow: TextOverflow.visible,
    //                 ),
    //                 Text(
    //                   'จำนวน: ${item['quantity']} ${item['unit_id']}',
    //                   style: TextStyle(
    //                     fontSize: 16,
    //                     fontFamily: Fonts.Fontnormal.fontFamily,
    //                   ),
    //                   maxLines: 1,
    //                   overflow: TextOverflow.ellipsis,
    //                   softWrap: false,
    //                 ),
    //               ],
    //             ),
    //           );
    //         }).toList(),
    //       ],
    //     ),
    //   ),
    // );
    Card(
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Row (Request Details) - Moved OUTSIDE the Table
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'หมายเลขคำขอ: ${request['request_id'] ?? ''}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                  Text(
                    'วันที่: $displayDate',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: Fonts.Fontnormal.fontFamily,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text(
                  //   'ผู้เบิก: ${request['username'] ?? ''}',
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontFamily: Fonts.Fontnormal.fontFamily,
                  //   ),
                  // ),
                  // Text(
                  //   'สถานะ: ${request['status']}',
                  //   style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Fonts.Fontnormal.fontFamily),
                  // ),
                  Row(
                    children: [
                      Text(
                        'สถานะ: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                      Text(
                        request['status'],
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                          color:
                              request['status'] == 'อนุมัติคำขอ'
                                  ? Colors.green[700]
                                  : (request['status'] == 'ปฏิเสธคำขอ'
                                      ? Colors.red
                                      : Colors.orange[500]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16), // Add spacing
              // Items Table
              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: IntrinsicColumnWidth(), // Column for the row number
                  1: FlexColumnWidth(3), // Material name
                  2: FlexColumnWidth(1), // Quantity
                  3: FlexColumnWidth(1), // Unit
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: [
                      Padding(
                        // Header for row number
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'ลำดับ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'วัสดุ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'จำนวน',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'หน่วยนับ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  // Table Rows (Items)
                  ...items.map<TableRow>((item) {
                    int index = items.indexOf(
                      item,
                    ); // Get the index of the item
                    return TableRow(
                      children: [
                        Padding(
                          // Row number
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${index + 1}', // Display row number (starting from 1)
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['mt_name'] ?? '',
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${item['quantity'] ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        ),
                        Padding(
                          // Display the unit
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${item['unit_id'] ?? ''}', // Unit from item data
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
