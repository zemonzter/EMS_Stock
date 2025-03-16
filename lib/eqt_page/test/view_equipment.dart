import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Equipment {
  final String hnId;
  final String eqName;
  final String eqBrand;
  final String eqModel;
  final String eqStatus;

  Equipment({
    required this.hnId,
    required this.eqName,
    required this.eqBrand,
    required this.eqModel,
    required this.eqStatus,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      hnId: json['HN_id'],
      eqName: json['eq_name'],
      eqBrand: json['eq_brand'],
      eqModel: json['eq_model'],
      eqStatus: json['eq_status'],
    );
  }
}

class EquipmentList extends StatefulWidget {
  EquipmentList({super.key});

  @override
  _EquipmentListState createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  late Future<List<Equipment>> _equipmentList;

  Future<List<Equipment>> _fetchEquipment() async {
    final response = await http.get(Uri.parse('${baseUrl}view_equipment.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Equipment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load equipment');
    }
  }

  @override
  void initState() {
    super.initState();
    _equipmentList = _fetchEquipment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายการครุภัณฑ์')),
      body: FutureBuilder<List<Equipment>>(
        future: _equipmentList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Equipment> equipment = snapshot.data!;
            return SingleChildScrollView(
              // เพิ่ม SingleChildScrollView เพื่อให้ตารางเลื่อนได้
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('HN ID')),
                  DataColumn(label: Text('ชื่อ')),
                  DataColumn(label: Text('ยี่ห้อ')),
                  DataColumn(label: Text('รุ่น')),
                  DataColumn(label: Text('สถานะ')),
                ],
                rows:
                    equipment
                        .map(
                          (eq) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(eq.hnId)),
                              DataCell(Text(eq.eqName)),
                              DataCell(Text(eq.eqBrand)),
                              DataCell(Text(eq.eqModel)),
                              DataCell(Text(eq.eqStatus)),
                            ],
                          ),
                        )
                        .toList(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
