import 'dart:convert';
import 'package:ems_condb/api_config.dart';
import 'package:ems_condb/eqt_page/util/models/dropdown_status.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditEquipmentPage extends StatefulWidget {
  final String hnId;
  final VoidCallback? onRefresh;

  EditEquipmentPage({required this.hnId, this.onRefresh});

  @override
  _EditEquipmentPageState createState() => _EditEquipmentPageState();
}

class _EditEquipmentPageState extends State<EditEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _hnIdController = TextEditingController();
  TextEditingController _eqTypeController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _eqNameController = TextEditingController();
  TextEditingController _eqBrandController = TextEditingController();
  TextEditingController _eqModelController = TextEditingController();
  TextEditingController _eqStatusController =
      TextEditingController(); // Keep for initial value
  TextEditingController _eqPriceController = TextEditingController();
  TextEditingController _eqBuyDateController = TextEditingController();
  TextEditingController _eqDateController = TextEditingController();
  TextEditingController _eqWarranController = TextEditingController();
  File? _image;
  String? _selectedStatus; // Store selected status *name*
  String? _selectedStatusId; //Store ID
  List<DropdownStatus> _statusList = [];

  Future<void> _fetchEquipmentData() async {
    final response = await http.get(Uri.parse('$baseUrl/view_equipment.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        var equipmentData = data.firstWhere(
          (element) => element['HN_id'] == widget.hnId,
          orElse: () => null,
        );

        if (equipmentData != null) {
          _hnIdController.text = equipmentData['HN_id'] ?? '';
          _eqTypeController.text = equipmentData['eq_type'] ?? '';
          _userNameController.text = equipmentData['user_name'] ?? '';
          _eqNameController.text = equipmentData['eq_name'] ?? '';
          _eqBrandController.text = equipmentData['eq_brand'] ?? '';
          _eqModelController.text = equipmentData['eq_model'] ?? '';
          _eqStatusController.text =
              equipmentData['eq_status'] ??
              ''; // Keep for finding initial dropdown value
          _eqPriceController.text = equipmentData['eq_price'] ?? '';
          _eqBuyDateController.text = equipmentData['eq_buydate'] ?? '';
          _eqDateController.text = equipmentData['eq_date'] ?? '';
          _eqWarranController.text = equipmentData['eq_warran'] ?? '';
          // NO setState here.  State is set after fetching the status list.
        } else {
          print('No equipment found with HN_id: ${widget.hnId}');
        }
      } else {
        print('Data format is incorrect: $data');
      }
    } else {
      print('Failed to load equipment data');
    }
  }

  Future<List<DropdownStatus>> getStatus() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}view_status.php"));
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as List;
        return body.map((e) {
          final map = e as Map<String, dynamic>;
          return DropdownStatus(
            status_id: map["status_id"], // Ensure string type
            status: map["status"],
          );
        }).toList();
      } else {
        // Handle non-200 status codes more explicitly
        throw Exception("Failed to load status data: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      // Catch any other errors, including json decoding errors.
      throw Exception("Fetch Data Error: $e");
    }
  }

  Future<void> _initializeData() async {
    await _fetchEquipmentData(); // Fetch equipment data
    _statusList = await getStatus(); // Fetch status list

    // Set the initial value for the dropdown
    if (mounted) {
      setState(() {
        // Find the matching DropdownStatus object and get the status name.
        final matchingStatus = _statusList.firstWhere(
          (status) => status.status == _eqStatusController.text,
          orElse:
              () => DropdownStatus(
                status_id: "",
                status: "",
              ), // Default if not found
        );
        _selectedStatus = matchingStatus.status;
        _selectedStatusId = matchingStatus.status_id;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData(); // Initialize data
  }

  Future _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateEquipment() async {
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update_equipment.php'),
      );

      request.fields['HN_id'] = _hnIdController.text;
      request.fields['eq_type'] = _eqTypeController.text;
      request.fields['user_name'] = _userNameController.text;
      request.fields['eq_name'] = _eqNameController.text;
      request.fields['eq_brand'] = _eqBrandController.text;
      request.fields['eq_model'] = _eqModelController.text;
      request.fields['eq_status'] =
          _selectedStatus ?? ''; // Use selected status *name*
      request.fields['eq_price'] = _eqPriceController.text;
      request.fields['eq_buydate'] = _eqBuyDateController.text;
      request.fields['eq_date'] = _eqDateController.text;
      request.fields['eq_warran'] = _eqWarranController.text;
      request.fields['old_HN_id'] =
          widget.hnId; // Use old_HN_id for WHERE clause

      // Add image if it's selected
      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _image!.path),
        );
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);

        if (data['success']) {
          widget.onRefresh?.call(); // Refresh the list
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('อัปเดตข้อมูลเรียบร้อย')));
          Navigator.pop(context); // Go back to the previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ')));
      }
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('แก้ไขครุภัณฑ์')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _hnIdController,
                decoration: InputDecoration(labelText: 'เลขครุภัณฑ์'),
                enabled: false, // HN_id should not be editable
              ),
              TextFormField(
                controller: _eqTypeController,
                decoration: InputDecoration(labelText: 'ประเภท'),
                enabled: false,
              ),
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'ผู้ใช้งาน'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอก ผู้ใช้งาน';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eqNameController,
                decoration: InputDecoration(labelText: 'ชื่อ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอก ชื่อ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eqBrandController,
                decoration: InputDecoration(labelText: 'ยี่ห้อ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอก ยี่ห้อ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eqModelController,
                decoration: InputDecoration(labelText: 'รุ่น'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอก รุ่น';
                  }
                  return null;
                },
              ),
              FutureBuilder<List<DropdownStatus>>(
                future: getStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    if (_selectedStatus == null && snapshot.data!.isNotEmpty) {
                      final equipmentStatus = _eqStatusController.text;

                      final matchingStatus = snapshot.data!.firstWhere(
                        (status) => status.status == equipmentStatus,
                        orElse:
                            () => DropdownStatus(
                              status_id: "",
                              status: "",
                            ), // Default if not found
                      );
                      _selectedStatus = matchingStatus.status;
                      _selectedStatusId = matchingStatus.status_id;
                    }

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'สถานะ'),
                      value: _selectedStatus, // Use status name
                      items:
                          snapshot.data!.map((DropdownStatus status) {
                            return DropdownMenuItem<String>(
                              value: status.status, // Value is status *name*
                              child: Text(status.status),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue;
                          // Find the corresponding ID
                          _selectedStatusId =
                              _statusList
                                  .firstWhere((s) => s.status == newValue)
                                  .status_id;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณาเลือกสถานะ';
                        }
                        return null;
                      },
                    );
                  } else {
                    return const Text('No data available');
                  }
                },
              ),
              // const SizedBox(height: 16),
              TextFormField(
                controller: _eqPriceController,
                decoration: InputDecoration(labelText: 'ราคา'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอก ราคา';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eqBuyDateController,
                decoration: InputDecoration(
                  labelText: 'วันที่ซื้อ',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _eqBuyDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาเลือกวันที่ซื้อ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eqDateController,
                decoration: InputDecoration(
                  labelText: 'วันที่เบิก',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _eqDateController),
              ),
              TextFormField(
                controller: _eqWarranController,
                decoration: InputDecoration(labelText: 'ประกัน (ปี)'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      // Make onPressed async
                      await _updateEquipment(); // Await the update

                      // Check if onRefresh is provided
                      widget.onRefresh?.call();
                    },
                    child: Text(
                      'บันทึกการแก้ไข',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('ยกเลิก'),
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
