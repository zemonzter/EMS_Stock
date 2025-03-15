import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart'; // Import the excel package
import 'package:ems_condb/api_config.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  List<List<dynamic>> _data = [];

  Future<void> uploadData() async {
    if (_data.isEmpty) {
      print("No data to upload.");
      return;
    }
    String url = "${baseUrl}import_mt.php"; // Your PHP script URL
    try {
      for (int i = 1; i < _data.length; i++) {
        // Skip header row (index 0)
        var row = _data[i];
        var request = http.MultipartRequest('POST', Uri.parse(url));

        // Add data fields to the request
        request.fields['mttype'] = row.isNotEmpty ? row[0].toString() : "";
        request.fields['mtname'] = row.length > 1 ? row[1].toString() : "";
        request.fields['unitid'] = row.length > 3 ? row[3].toString() : "";
        request.fields['mtstock'] = row.length > 2 ? row[2].toString() : "";
        request.fields['unitprice'] = row.length > 4 ? row[4].toString() : "";
        request.fields['mtprice'] = row.length > 5 ? row[5].toString() : "";
        request.fields['mtdate'] = row.length > 6 ? row[6].toString() : "";
        request.fields['mtlink'] = row.length > 7 ? row[7].toString() : "";

        // Handle image upload if available (assuming it's in the 8th column)
        if (row.length > 8 && row[8] != null) {
          String imageName = 'image_$i.jpg'; // Or generate a unique name
          request.files.add(
            http.MultipartFile.fromString(
              'image', // The name your PHP expects for the image
              base64Encode(row[8]), // Assuming image data is base64 encoded
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
      appBar: AppBar(title: const Text("อัปโหลดข้อมูลวัสดุ")),
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
                onPressed: () {
                  uploadData();
                  Navigator.pop(context);
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
