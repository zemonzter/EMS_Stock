import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _generatePdf(
  List<Map<String, dynamic>> requests,
  String? selectedUserName,
  DateTime? selectedStartDate,
  DateTime? selectedEndDate,
  String? selectedStatus,
) async {
  initializeDateFormatting('th');

  final pdf = pw.Document();
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
          pw.Table.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: pw.TextStyle(font: font, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['ชื่ออุปกรณ์', 'ผู้เบิก', 'จำนวน', 'วันที่', 'สถานะ'],
            columnWidths: {
              0: const pw.FixedColumnWidth(90),
              1: const pw.FixedColumnWidth(70),
              2: const pw.FixedColumnWidth(30),
              3: const pw.FixedColumnWidth(50),
              4: const pw.FixedColumnWidth(30),
            },
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            headerAlignment: pw.Alignment.center,
            data:
                requests.map((request) {
                  return [
                    request['mt_name'] ?? '',
                    request['username'] ?? '',
                    '${request['quantity'] ?? ''} ${request['unit'] ?? ''}',
                    formatRequestDate(request['date'], font),
                    request['status'] ?? '',
                  ];
                }).toList(),
          ),
          pw.SizedBox(height: 20),
          ...requests.map((request) {
            if (request['items'] is List) {
              List<dynamic> itemsList = request['items'];
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'รายการวัสดุสำหรับ: หมายเลขคำขอ ${request['request_id'] ?? ''}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'สถานะ: ${request['status'] ?? ''}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ผู้เบิก: ${request['username'] ?? ''}',
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
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
                    headers: ['วัสดุ', 'จำนวน'],
                    columnWidths: {
                      0: const pw.FixedColumnWidth(120),
                      1: const pw.FixedColumnWidth(60),
                    },
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.center,
                    },
                    data:
                        itemsList.map<List<String>>((item) {
                          return [
                            item['mt_name'] ?? '',
                            '${item['quantity'] ?? ''} ${item['unit_id'] ?? ''}',
                          ];
                        }).toList(),
                  ),
                ],
              );
            } else {
              return pw.Container();
            }
          }).toList(),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

// Helper function to format dates in Thai Buddhist Era (B.E.)
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
    return 'Invalid Date';
  }
}
