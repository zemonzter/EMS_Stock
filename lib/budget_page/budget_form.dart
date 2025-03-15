import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class BudgetForm extends StatefulWidget {
  const BudgetForm({super.key, this.onBudgetAdded}); // Add callback
  final VoidCallback? onBudgetAdded; // Callback function

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _budgetTypes = ["ครุภัณฑ์", "วัสดุ"]; // List of budget types
  String? _selectedType; // Make _selectedType nullable
  final _formKey = GlobalKey<FormState>(); // Add form key

  TextEditingController budgettype = TextEditingController();
  TextEditingController budgetname = TextEditingController();
  TextEditingController budgetamount = TextEditingController();
  TextEditingController budgetyear = TextEditingController();

  Future<void> budgetForm() async {
    final formState = _formKey.currentState; // Get current state of the form.

    if (formState != null && formState.validate() && _selectedType != null) {
      try {
        String uri = "${baseUrl}budget_form.php";

        var res = await http.post(
          Uri.parse(uri),
          body: {
            "budgettype": _selectedType, // Send the selected type
            "budgetname": budgetname.text,
            "budgetamount": budgetamount.text,
            "budgetyear": budgetyear.text,
          },
        );

        var response = jsonDecode(res.body);
        if (response['success'] == 'true') {
          print("Record inserted successfully");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'เพิ่มข้อมูลงบประมาณสำเร็จ',
                style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Call the callback function after successful insertion
          if (widget.onBudgetAdded != null) {
            widget.onBudgetAdded!();
          }
          Navigator.pop(context, true); // Close and return true
        } else {
          print("Error inserting record");
          ScaffoldMessenger.of(context).showSnackBar(
            // Show error SnackBar
            SnackBar(
              content: Text(
                'เกิดข้อผิดพลาด: ${response['message'] ?? 'ไม่สามารถเพิ่มข้อมูลงบประมาณได้'}',
                style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาด: $e',
              style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Navigator.pop(context, true); // Remove this. Keep form open on error.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'กรุณากรอกข้อมูลให้ครบถ้วน', // Correct message.
      //       style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
      //     ),
      //     backgroundColor: Colors.red, // Good practice: red for errors
      //   ),
      // );
      print("please fill all the details"); // Keep for debugging.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          // centerTitle: true,
          title: Text(
            "ฟอร์มงบประมาณ",
            style: TextStyle(
              color: Colors.white,
              fontFamily: GoogleFonts.mali().fontFamily,
            ),
          ),
          backgroundColor: const Color(0xFF7E0101),
          toolbarHeight: 120,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              // Wrap with Form widget
              key: _formKey, // Assign the form key
              child: Column(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        // Specify the type <String>
                        value: _selectedType, // Set initial value
                        items:
                            _budgetTypes
                                .map(
                                  (type) => DropdownMenuItem<String>(
                                    // Specify type here too
                                    value: type,
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.mali().fontFamily,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType =
                                value; // Update selected type, no cast needed
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'กรุณาเลือกประเภทงบประมาณ';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "ประเภทงบประมาณ",
                          labelStyle: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: budgetname,
                        decoration: InputDecoration(
                          labelText: "รายละเอียดงบประมาณ",
                          labelStyle: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกรายละเอียดงบประมาณ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: budgetamount,
                        decoration: InputDecoration(
                          labelText: "จำนวนเงิน",
                          labelStyle: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกจำนวนเงิน';
                          }
                          if (double.tryParse(value) == null) {
                            return 'กรุณากรอกตัวเลข';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: budgetyear,
                        decoration: InputDecoration(
                          labelText: "ปีงบประมาณ",
                          labelStyle: TextStyle(
                            fontFamily: GoogleFonts.mali().fontFamily,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกปีงบประมาณ';
                          }
                          if (int.tryParse(value) == null) {
                            return 'กรุณากรอกตัวเลข';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                budgetForm(); // Call the function
                              },
                              child: Text(
                                'ยืนยัน',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.mali().fontFamily,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'ยกเลิก',
                                style: TextStyle(
                                  fontFamily: GoogleFonts.mali().fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
