import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems_condb/util/font.dart';

class EditBudget extends StatefulWidget {
  final Map<String, dynamic> budgetData;

  const EditBudget({Key? key, required this.budgetData}) : super(key: key);

  @override
  _EditBudgetState createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _budgetNameController;
  late TextEditingController _budgetAmountController;
  late TextEditingController _budgetYearController;
  late String _selectedBudgetType;

  // Store initial values for comparison
  late String _initialBudgetName;
  late String _initialBudgetAmount;
  late String _initialBudgetYear;
  late String _initialBudgetType;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from budgetData
    _budgetNameController = TextEditingController(
      text: widget.budgetData['budget_name'],
    );
    _budgetAmountController = TextEditingController(
      text: widget.budgetData['budget_amount'].toString(),
    );
    _budgetYearController = TextEditingController(
      text: widget.budgetData['budget_year'].toString(),
    );
    _selectedBudgetType =
        widget.budgetData['budget_type']; // Initialize with existing value

    // Handle potential null value for budget_type (optional, good practice)
    if (_selectedBudgetType == null || _selectedBudgetType.isEmpty) {
      _selectedBudgetType = 'วัสดุ'; // Default to "วัสดุ" if null or empty
    }

    // Store the initial values *after* setting the controllers
    _initialBudgetName = _budgetNameController.text;
    _initialBudgetAmount = _budgetAmountController.text;
    _initialBudgetYear = _budgetYearController.text;
    _initialBudgetType = _selectedBudgetType;
  }

  @override
  void dispose() {
    // Clean up controllers
    _budgetNameController.dispose();
    _budgetAmountController.dispose();
    _budgetYearController.dispose();
    super.dispose();
  }

  // Helper function to show dialogs (good practice for code reuse)
  void _showDialog(
    BuildContext context,
    String title,
    String message, {
    bool shouldPop = false,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (shouldPop) {
                  Navigator.of(context).pop(true); // Pop again for navigation
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      String uri = "${baseUrl}update_budget.php";

      // Create a map to store only the changed fields
      Map<String, dynamic> updatedData = {
        'budget_id': widget.budgetData['budget_id'].toString(),
      };

      // Check if each field has changed and add it to the map if it has.
      if (_budgetNameController.text != _initialBudgetName) {
        updatedData['budget_name'] = _budgetNameController.text;
      }
      if (_budgetAmountController.text != _initialBudgetAmount) {
        updatedData['budget_amount'] = _budgetAmountController.text;
      }
      if (_budgetYearController.text != _initialBudgetYear) {
        updatedData['budget_year'] = _budgetYearController.text;
      }
      if (_selectedBudgetType != _initialBudgetType) {
        updatedData['budget_type'] = _selectedBudgetType;
      }

      // If no fields have changed, *don't* send a request
      if (updatedData.length == 1) {
        // Only budget_id is present
        if (mounted) {
          _showDialog(context, "Info", "No changes were made.");
        }
        return; // Exit the function
      }

      try {
        // Send only the changed data
        var response = await http.post(
          Uri.parse(uri),
          body: updatedData, // Use the map with changed fields
        );

        var data = jsonDecode(response.body); //Correctly decode
        if (data['status'] == 'success') {
          if (mounted) {
            _showDialog(
              context,
              "สำเร็จ",
              "ข้อมูลงบประมาณได้รับการอัปเดต!",
              shouldPop: true,
            );
          }
        } else {
          if (mounted) {
            _showDialog(
              context,
              "เกิดข้อผิดพลาด",
              "Failed to update budget: ${data['message']}",
            );
          }
        }
      } catch (e) {
        if (mounted) {
          _showDialog(context, "Error", "Exception: $e");
        }
      }
    }
  }

  Future<void> _deleteBudget() async {
    // 1. Show a confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('แน่ใจว่าต้องการลบงบประมาณ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(false), // Return false
            ),
            TextButton(
              child: const Text('ลบ'),
              onPressed: () => Navigator.of(context).pop(true), // Return true
            ),
          ],
        );
      },
    );

    // 2. If the user confirms, proceed with deletion
    if (confirmDelete == true) {
      String uri = "${baseUrl}delete_budget.php";

      try {
        var response = await http.post(
          Uri.parse(uri),
          body: {'budget_id': widget.budgetData['budget_id'].toString()},
        );

        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          if (mounted) {
            _showDialog(
              context,
              "สำเร็จ",
              "ลบข้อมูลงบประมาณเสร็จสิ้น!",
              shouldPop: true,
            );
          }
        } else {
          if (mounted) {
            _showDialog(
              context,
              "Error",
              "Failed to delete budget: ${data['message']}",
            );
          }
        }
      } catch (e) {
        if (mounted) {
          _showDialog(context, "Error", "Exception: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขข้อมูลงบประมาณ',
          style: TextStyle(
            color: Colors.white,
            fontFamily: Fonts.Fontnormal.fontFamily,
          ),
        ),
        backgroundColor: const Color(0xFF7E0101),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _budgetNameController,
                decoration: InputDecoration(
                  labelText: 'รายละเอียดงบประมาณ',
                  labelStyle: TextStyle(
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรายละเอียดงบประมาณ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _budgetAmountController,
                decoration: InputDecoration(
                  labelText: 'จำนวนงบประมาณ (บาท)',
                  labelStyle: TextStyle(
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกจำนวนงบประมาณ';
                  }
                  if (double.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _budgetYearController,
                decoration: InputDecoration(
                  labelText: 'ปีงบประมาณ (พ.ศ.)',
                  labelStyle: TextStyle(
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกปีงบประมาณ (พ.ศ.)';
                  }
                  if (int.tryParse(value) == null) {
                    return 'กรุณากรอกปีที่ถูกต้อง';
                  }
                  if (value.length != 4) {
                    return 'กรุณากรอกปีให้ถูกต้อง (ตัวเลข 4 หลัก)';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedBudgetType,
                decoration: InputDecoration(
                  labelText: 'ประเภทงบประมาณ',
                  labelStyle: TextStyle(
                    fontFamily: Fonts.Fontnormal.fontFamily,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'ครุภัณฑ์', child: Text('ครุภัณฑ์')),
                  DropdownMenuItem(value: 'วัสดุ', child: Text('วัสดุ')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBudgetType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเลือกประเภทงบประมาณ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveChanges, // Use _saveChanges here
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // Text color
                    ),
                    child: Text(
                      'แก้ไขข้อมูลงบประมาณ', // Corrected text
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _deleteBudget,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red, // Text color
                    ),
                    child: Text(
                      'ลบงบประมาณ',
                      style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
