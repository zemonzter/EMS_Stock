import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart'; // Import the excel package

class ImportEqPage extends StatefulWidget {
  const ImportEqPage({super.key});

  @override
  State<ImportEqPage> createState() => _ImportEqPageState();
}

class _ImportEqPageState extends State<ImportEqPage> {
  List<List<dynamic>> _data = [];

  Future<bool> _checkDuplicateHNId(String hnId) async {
    String url = "${baseUrl}check_duplicate_hnid.php?HN_id=$hnId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['duplicate'] == true;
      } else {
        print('Failed to check duplicate HN_id: ${response.statusCode}');
        return false; // Assume duplicate to prevent upload in case of error
      }
    } catch (e) {
      print('Error checking duplicate HN_id: $e');
      return false; // Assume duplicate to prevent upload in case of error
    }
  }

  Future<void> uploadData() async {
    if (_data.isEmpty) {
      print("No data to upload.");
      return;
    }
    String url = "${baseUrl}import_eq.php"; // Your PHP script URL
    try {
      for (int i = 1; i < _data.length; i++) {
        var row = _data[i];
        var eqType = row.isNotEmpty ? row[0].toString().trim() : "";
        // Check eq_type
        if (eqType != "ครุภัณฑ์สำนักงาน" && eqType != "ครุภัณฑ์คอมพิวเตอร์") {
          if (mounted) {
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      'ประเภทครุภัณฑ์ไม่ถูกต้อง',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    content: Text(
                      'ประเภทครุภัณฑ์ "$eqType" ไม่ได้รับอนุญาต',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'ตกลง',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          }
          continue; // Skip to the next row
        }
        var hnId = row.length > 1 ? row[1].toString() : "";

        if (await _checkDuplicateHNId(hnId)) {
          if (mounted) {
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      'เลขครุภัณฑ์ซ้ำ',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    content: Text(
                      'เลขครุภัณฑ์ $hnId มีอยู่แล้วในระบบ',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'ตกลง',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          }
          continue;
        }
        var request = http.MultipartRequest('POST', Uri.parse(url));

        // Add data fields to the request
        request.fields['eq_type'] = row.isNotEmpty ? row[0].toString() : "";
        request.fields['HN_id'] = row.length > 1 ? row[1].toString() : "";
        request.fields['user_name'] = row.length > 2 ? row[2].toString() : "";
        request.fields['eq_name'] = row.length > 3 ? row[3].toString() : "";
        request.fields['eq_brand'] = row.length > 4 ? row[4].toString() : "";
        request.fields['eq_model'] = row.length > 5 ? row[5].toString() : "";
        request.fields['eq_status'] = row.length > 6 ? row[6].toString() : "";
        request.fields['eq_price'] = row.length > 7 ? row[7].toString() : "";
        request.fields['eq_buydate'] = row.length > 8 ? row[8].toString() : "";
        request.fields['eq_date'] = row.length > 9 ? row[9].toString() : "";
        request.fields['eq_warran'] = row.length > 10 ? row[10].toString() : "";

        // Handle image upload if available (assuming it's in the 9th column)
        if (row.length > 11 && row[11] != null) {
          String imageName = 'image_$i.jpg'; // Or generate a unique name
          request.files.add(
            http.MultipartFile.fromString(
              'image', // The name your PHP expects for the image
              base64Encode(row[11]), // Assuming image data is base64 encoded
              filename: imageName,
            ),
          );
          request.fields['name'] = imageName;
        }

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          print('Uploaded row $i: $responseBody');
        } else {
          print('Error uploading row $i: ${response.statusCode}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data uploaded successfully!')),
      );
    } catch (e) {
      print('Error uploading data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("อัปโหลดข้อมูลครุภัณฑ์")),
      body: Column(
        children: [
          Expanded(
            child:
                _data.isEmpty
                    ? const Center(
                      child: Text(
                        "กรุณาจัดเตรียมข้อมูลในรูปแบบไฟล์ .csv หรือ .xls\nโดยจัดเรียงข้อมูลตามแม่แบบ",
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.all(3),
                          color: index == 0 ? Colors.amber : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: List.generate(_data[index].length, (
                                columnIndex,
                              ) {
                                return Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      _data[index][columnIndex].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: index == 0 ? 16 : 14,
                                        fontWeight:
                                            index == 0
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            index == 0
                                                ? Colors.red
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          if (_data.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _pickFile,
                child: const Text("เลือกไฟล์"),
              ),
            ),
          if (_data.isNotEmpty) // Conditionally show the upload button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  await uploadData();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("อัปโหลดข้อมูล"),
              ),
            ),
        ],
      ),
    );
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'], // Allow CSV and Excel files
    );

    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.first.bytes;
        if (fileBytes != null) {
          final fileName = result.files.first.name;
          if (fileName.endsWith('.csv')) {
            final data = utf8.decode(fileBytes);
            final fields = const CsvToListConverter().convert(data);
            setState(() {
              _data = fields;
            });
          } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
            var excel = Excel.decodeBytes(fileBytes);
            List<List<dynamic>> excelData = [];
            for (var table in excel.tables.values) {
              for (var row in table.rows) {
                excelData.add(row.map((cell) => cell?.value).toList());
              }
            }
            setState(() {
              _data = excelData;
            });
          }
        }
      } else {
        var filePath = result.files.first.path!;
        final fileName = result.files.first.name;

        if (fileName.endsWith('.csv')) {
          final input = File(filePath).openRead();
          final fields =
              await input
                  .transform(utf8.decoder)
                  .transform(const CsvToListConverter())
                  .toList();
          setState(() {
            _data = fields;
          });
        } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
          var bytes = File(filePath).readAsBytesSync();
          var excel = Excel.decodeBytes(bytes);
          List<List<dynamic>> excelData = [];
          for (var table in excel.tables.values) {
            for (var row in table.rows) {
              excelData.add(row.map((cell) => cell?.value).toList());
            }
          }
          setState(() {
            _data = excelData;
          });
        }
      }
    }
  }
}
