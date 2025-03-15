import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CheckoutReportPage extends StatefulWidget {
  final String? token;
  const CheckoutReportPage({super.key, this.token});

  @override
  State<CheckoutReportPage> createState() => _CheckoutReportPageState();
}

class _CheckoutReportPageState extends State<CheckoutReportPage> {
  List<Map<String, dynamic>> checkoutData = [];
  List<String> userNames = [];
  String? selectedUserName;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String? selectedStatus; // เพิ่มตัวแปรสำหรับเก็บสถานะที่เลือก

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
        _getCheckoutReport();
      } else {
        print('Failed to fetch user names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user names: $e');
    }
  }

  Future<void> _getCheckoutReport() async {
    String uri = "${baseUrl}view_checkout_report.php";
    try {
      var response = await http.get(Uri.parse(uri));
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> allCheckoutData =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // กรองข้อมูล
        setState(() {
          checkoutData =
              allCheckoutData.where((item) {
                final date = DateTime.parse(item['date']);
                // กรองตามชื่อผู้ใช้
                final isUserMatch =
                    selectedUserName == null ||
                    item['username'] == selectedUserName;
                // กรองตามวันที่
                final isDateMatch =
                    (selectedStartDate == null ||
                        date.isAtSameMomentAs(selectedStartDate!) ||
                        date.isAfter(selectedStartDate!)) &&
                    (selectedEndDate == null ||
                        date.isAtSameMomentAs(selectedEndDate!) ||
                        date.isBefore(selectedEndDate!));
                // กรองตามสถานะ
                final isStatusMatch =
                    selectedStatus == null || item['status'] == selectedStatus;

                return isUserMatch && isDateMatch && isStatusMatch;
              }).toList();
        });
      } else {
        print('Failed to fetch checkout report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching checkout report: $e');
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    // Define a Thai font (you might need to load a .ttf file)
    final font = await PdfGoogleFonts.sarabunRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                "รายงานการเบิก",
                style: pw.TextStyle(
                  font: font,
                  fontSize: 16,
                ), // Reduced header size
              ),
            ),
            if (selectedUserName != null)
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "ผู้เบิก: $selectedUserName",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                  ), // Reduced font size
                ),
              ),
            if (selectedStartDate != null)
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "วันที่เริ่มต้น: ${DateFormat('dd MMM yyy').format(selectedStartDate!)}",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                  ), // Reduced font size
                ),
              ),
            if (selectedEndDate != null)
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "วันที่สิ้นสุด: ${DateFormat('dd MMM yyy').format(selectedEndDate!)}",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                  ), // Reduced font size
                ),
              ),
            if (selectedStatus != null) // เพิ่มเงื่อนไขแสดงสถานะ
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  "สถานะ: $selectedStatus",
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ),
            pw.Table.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10, // Reduced header font size
              ),
              cellStyle: pw.TextStyle(
                font: font,
                fontSize: 10,
              ), // Reduced cell font size
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              headers: ['ชื่ออุปกรณ์', 'ผู้เบิก', 'จำนวน', 'วันที่', 'สถานะ'],
              columnWidths: {
                0: const pw.FixedColumnWidth(90), // Width for 'ชื่ออุปกรณ์'
                1: const pw.FixedColumnWidth(70), // Width for 'ผู้เบิก'
                2: const pw.FixedColumnWidth(30), // Width for 'จำนวน'
                3: const pw.FixedColumnWidth(50), // Width for 'วันที่'
                4: const pw.FixedColumnWidth(30), // Width for 'สถานะ'
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft, // Align 'ชื่ออุปกรณ์' to the left
                1: pw.Alignment.center, // Center other columns
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
              },
              headerAlignment: pw.Alignment.center,
              data:
                  checkoutData.map((item) {
                    final formattedDate = DateFormat(
                      'dd MMM yyy',
                    ).format(DateTime.parse(item['date']));
                    return [
                      item['mt_name'],
                      item['username'],
                      '${item['quantity']} ${item['unit']}',
                      formattedDate,
                      item['status'],
                    ];
                  }).toList(),
            ),
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
                              // เพิ่ม Dropdown สำหรับสถานะ
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
                                  value: 'approved',
                                  child: Text(
                                    'อนุมัติคำขอ',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'pending',
                                  child: Text(
                                    'รออนุมัติ',
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'rejected',
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
                          _getCheckoutReport();
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
          userNames.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : checkoutData.isEmpty
              ? Center(
                child: Text(
                  "ไม่มีข้อมูล",
                  style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
                ),
              )
              : ListView.builder(
                itemCount: checkoutData.length,
                itemBuilder: (context, index) {
                  final item = checkoutData[index];
                  final formattedDate = DateFormat(
                    'dd MMM yyy',
                  ).format(DateTime.parse(item['date']));
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['mt_name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ผู้เบิก: ${item['username']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                          Text(
                            'จำนวน: ${item['quantity']} ${item['unit']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                          Text(
                            'วันที่: $formattedDate',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          ),
                          Text(
                            'สถานะ: ${item['status']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
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
