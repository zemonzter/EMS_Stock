import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/user_page/settings/setting_eq/inserteqt.dart';
import 'package:ems_condb/util/block.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List eqtdata = [];
  List record = [];

  Future<void> getrecord() async {
    String uri = "${baseUrl}view_eqt.php";
    try {
      var response = await http.get(Uri.parse(uri));

      setState(() {
        eqtdata = jsonDecode(response.body);
        record = jsonDecode(response.body);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getrecord();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดการครุภัณฑ์"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsertPage()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: record.length,
        itemBuilder: (context, index) {
          final String name = eqtdata[index]['eqt_name'] ?? '';
          final String image = (baseUrl + record[index]["eqt_img"] ?? "");
          //final String image = (record[index]["http://10.0.2.2/test_condb/"] ?? "") + "/test_condb";

          return SafeArea(
            // child: Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.all(16.0),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlockDetail(
                        blockName: name,
                        blockImage: image,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
                // ),
              ),
            ),
          );
        },
      ),
    );
  }
}
