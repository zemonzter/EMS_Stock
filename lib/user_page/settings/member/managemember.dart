import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_role.dart';
import 'edit_role.dart';

class ManageMember extends StatefulWidget {
  const ManageMember({super.key});

  @override
  State<ManageMember> createState() => _ManageMemberState();
}

class _ManageMemberState extends State<ManageMember> {
  List roles = [];

  Future<void> getRoles() async {
    String uri = "${baseUrl}view_role.php";
    try {
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);

        if (decodedResponse is List) {
          setState(() {
            roles = decodedResponse;
          });
        } else if (decodedResponse['success'] == 'false') {
          print("Error fetching roles: ${decodedResponse['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${decodedResponse['message']}")),
          );
        } else {
          print("Unexpected response format: ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unexpected error occurred.")),
          );
        }
      } else {
        print("HTTP request failed with status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("HTTP Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error fetching roles: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    getRoles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "จัดการสิทธิ์การใช้งาน",
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRole()),
              );
              if (result != null && result == true) {
                getRoles();
              }
            },
            icon: const Icon(Icons.add),
            tooltip: "เพิ่มสิทธิ์การใช้งาน",
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width:
              Responsive.isDesktop(context)
                  ? 1000
                  : Responsive.isTablet(context)
                  ? 700
                  : double.infinity,
          child: ListView.builder(
            itemCount: roles.length,
            itemBuilder: (context, index) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRole(role: roles[index]),
                        ),
                      );
                      if (result != null && result == true) {
                        getRoles(); // Refresh the list after edit/delete
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roles[index]["role"],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              roles[index]["description"] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
