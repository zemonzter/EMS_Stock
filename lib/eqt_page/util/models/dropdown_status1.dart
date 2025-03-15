import 'dart:convert';
import 'dart:io';
import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DropdownStatusAPI extends StatefulWidget {
  const DropdownStatusAPI({super.key});

  @override
  State<DropdownStatusAPI> createState() => _DropdownStatusAPIState();
}

class DropdownStatus {
  String status_id;
  String status;

  DropdownStatus({required this.status_id, required this.status});

  factory DropdownStatus.fromJson(Map<String, dynamic> json) =>
      DropdownStatus(status_id: json["status_id"], status: json["status"]);

  Map<String, dynamic> toJson() => {"status_id": status_id, "status": status};
}

class _DropdownStatusAPIState extends State<DropdownStatusAPI> {
  Future<List<DropdownStatus>> getPost() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}view_status.php"));
      final body = json.decode(response.body) as List;

      if (response.statusCode == 200) {
        return body.map((e) {
          final map = e as Map<String, dynamic>;
          return DropdownStatus(
            status_id: map["status_id"],
            status: map["status"],
          );
        }).toList();
      }
    } on SocketException {
      throw Exception('No Internet connection');
    }
    throw Exception("Fetch Data Error");
  }

  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Dropdown from API")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          FutureBuilder<List<DropdownStatus>>(
            future: getPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    label: const Text("สถานะ"),
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                  value: selectedValue,
                  dropdownColor: Colors.deepPurple[100],
                  isExpanded: true,
                  hint: const Text("Select Item"),
                  items:
                      snapshot.data!.map((e) {
                        return DropdownMenuItem(
                          value: e.status,
                          child: Text(e.status),
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
