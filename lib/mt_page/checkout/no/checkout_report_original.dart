import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
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
                return isUserMatch && isDateMatch;
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

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'รายงานการเบิก (${selectedUserName ?? 'ทั้งหมด'})',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              if (checkoutData.isNotEmpty)
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(80),
                    1: const pw.FixedColumnWidth(100),
                    2: const pw.FixedColumnWidth(60),
                    3: const pw.FixedColumnWidth(80),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text(
                          'วัสดุ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'ผู้เบิก',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'จำนวน',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'เวลา',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    for (var item in checkoutData)
                      pw.TableRow(
                        children: [
                          pw.Text(item['mt_name']),
                          pw.Text(item['username']),
                          pw.Text('${item['quantity']} ' + item['unit']),
                          pw.Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(DateTime.parse(item['date'])),
                          ),
                        ],
                      ),
                  ],
                )
              else
                pw.Text("ไม่มีข้อมูล"),
            ],
          );
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
        title: const Text(
          'รายงานการเบิก',
          style: TextStyle(color: Colors.white),
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
                    title: const Text('เลือกผู้ใช้'),
                    content: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // DropdownButton<String>(
                            //   value: selectedUserName,
                            //   items: userNames.map((String value) {
                            //     return DropdownMenuItem<String>(
                            //       value: value,
                            //       child: Text(value),
                            //     );
                            //   }).toList(),

                            //   onChanged: (newValue) {
                            //     setState(() {
                            //       selectedUserName = newValue;
                            //     });
                            //   },
                            //   hint: const Text('เลือกผู้ใช้'),
                            // ),
                            DropdownButton<String>(
                              value: selectedUserName,
                              items: [
                                // เพิ่ม "บุคคลากรทั้งหมด" ที่นี่
                                const DropdownMenuItem<String>(
                                  value:
                                      null, // กำหนด value เป็น null เพื่อให้แสดงข้อมูลทั้งหมด
                                  child: Text('บุคคลากรทั้งหมด'),
                                ),
                                // ... (รายชื่อผู้ใช้เดิม)
                                ...userNames.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  selectedUserName = newValue;
                                });
                              },
                              hint: const Text('เลือกผู้ใช้'),
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
                              child: const Text('เลือกวันเริ่มต้น'),
                            ),
                            const SizedBox(height: 10),
                            if (selectedStartDate != null)
                              Text(
                                'วันเริ่มต้น: ${DateFormat('dd MMM yyyy').format(selectedStartDate!)}',
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
                              child: const Text('เลือกวันสิ้นสุด'),
                            ),
                            const SizedBox(height: 10),
                            if (selectedEndDate != null)
                              Text(
                                'วันสิ้นสุด: ${DateFormat('dd MMM yyyy').format(selectedEndDate!)}',
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
                        child: const Text('ตกลง'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('ยกเลิก'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.sort),
          ),
          IconButton(onPressed: _generatePdf, icon: const Icon(Icons.print)),
        ],
      ),
      body:
          userNames.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : checkoutData.isEmpty
              ? const Center(child: Text("ไม่มีข้อมูล"))
              : ListView.builder(
                itemCount: checkoutData.length,
                itemBuilder: (context, index) {
                  final item = checkoutData[index];
                  final formattedDate = DateFormat(
                    'dd MMM yyyy',
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow:
                                TextOverflow
                                    .ellipsis, //ตัดข้อความเหลือ 1 บรรทัด
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ผู้เบิก: ${item['username']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'จำนวน: ${item['quantity']} ${item['unit']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'วันที่: $formattedDate',
                            style: const TextStyle(fontSize: 16),
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
