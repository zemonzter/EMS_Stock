import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import '../util/models/dropdown_model.dart';
import 'package:http/http.dart' as http;

//

class DropdownFromAPI extends StatefulWidget {
  const DropdownFromAPI({super.key});

  @override
  State<DropdownFromAPI> createState() => _DropdownFromAPIState();
}

class _DropdownFromAPIState extends State<DropdownFromAPI> {
  Future<List<DropdownModel>> getPost() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}view_eqt.php"));
      // final response = await http.get(Uri.parse("${url}view_eqt.php"));
      final body = json.decode(response.body) as List;

      if (response.statusCode == 200) {
        return body.map((e) {
          final map = e as Map<String, dynamic>;
          return DropdownModel(eqtId: map["eqt_id"], eqtName: map["eqt_name"]);
        }).toList();
      }
    } on SocketException {
      throw Exception('No Internet connection');
    }
    throw Exception("Fetch Data Error");
  }

  var selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Dropdown from API")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          FutureBuilder<List<DropdownModel>>(
            future: getPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    label: const Text("ประเภทครุภัณฑ์"),
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                  value: selectedValue,
                  dropdownColor: Colors.deepPurple[100],
                  isExpanded: true, //ยาวเต็มหน้าจอ
                  hint: const Text("Select Item"),
                  items:
                      snapshot.data!.map((e) {
                        return DropdownMenuItem(
                          value: e.eqtName.toString(),
                          child: Text(e.eqtName.toString()),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}
