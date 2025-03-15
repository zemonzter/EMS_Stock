import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:http/http.dart' as http;
import 'package:ems_condb/user_page/settings/member/add_member.dart';
import 'package:ems_condb/user_page/settings/member/edit_member.dart'; // Import EditMember
import 'package:flutter/material.dart';

//

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  List users = [];

  Future<void> getUsers() async {
    String uri = "${baseUrl}view_user.php";
    try {
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);

        if (decodedResponse is List) {
          setState(() {
            users = decodedResponse;
          });
        } else if (decodedResponse['success'] == 'false') {
          print("Error fetching users: ${decodedResponse['message']}");
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
      print("Error fetching users: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "รายชื่อสมาชิก",
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
                MaterialPageRoute(builder: (context) => const AddMember()),
              );
              if (result != null && result == true) {
                getUsers(); // Refresh the list after adding a member
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'เพิ่มสมาชิก',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(
              users[index]["user_name"],
              style: TextStyle(
                fontFamily: Fonts.Fontnormal.fontFamily,
                fontSize: Responsive.isDesktop(context) ? 20 : 16,
              ),
            ),
            subtitle: Text(
              users[index]["user_email"],
              style: TextStyle(
                fontFamily: Fonts.Fontnormal.fontFamily,
                fontSize: Responsive.isDesktop(context) ? 16 : 12,
              ),
            ),
            trailing: Text(
              users[index]["user_role"],
              style: TextStyle(
                fontFamily: Fonts.Fontnormal.fontFamily,
                fontSize: Responsive.isDesktop(context) ? 16 : 12,
              ),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMember(userData: users[index]),
                ),
              );
              if (result != null && result == true) {
                getUsers(); // Refresh the list after editing
              }
            },
          );
        },
      ),
    );
  }
}
