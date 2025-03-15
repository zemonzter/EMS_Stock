import 'dart:convert';
import 'dart:io';

import 'package:ems_condb/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({super.key});

  @override
  State<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _eqtnameController = TextEditingController();
  final _useridController = TextEditingController();
  final _eqnameController = TextEditingController();
  final _eqmodelController = TextEditingController();
  final _eqbrandController = TextEditingController();
  final _eqserialController = TextEditingController();
  final _eqstatusController = TextEditingController();
  final _eqpriceController = TextEditingController();
  final _eqwarranController = TextEditingController();
  final _quantityController = TextEditingController(
    text: '1',
  ); // Initialize with 1

  DateTime? _eqbuydate;
  DateTime? _eqdate;

  // Image variable
  File? _image;
  final _picker = ImagePicker();
  String? _base64Image; // Store base64 encoded image

  // Function to pick an image
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Convert image to base64
      List<int> imageBytes = await _image!.readAsBytes();
      _base64Image = base64Encode(imageBytes);
    }
  }

  // Function to handle date selection
  Future<void> _selectDate(BuildContext context, bool isBuyDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBuyDate) {
          _eqbuydate = picked;
        } else {
          _eqdate = picked;
        }
      });
    }
  }

  // Function to handle form submission (NOW HANDLES MULTIPLE INSERTS)
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      int quantity =
          int.tryParse(_quantityController.text) ??
          1; // Default to 1 if parsing fails
      if (quantity <= 0) {
        quantity = 1; // Ensure at least one item is added.
      }

      for (int i = 0; i < quantity; i++) {
        // Build the request body
        Map<String, String> body = {
          'eqtname': _eqtnameController.text,
          'userid': _useridController.text,
          'eqname': _eqnameController.text,
          'eqmodel': _eqmodelController.text,
          'eqbrand': _eqbrandController.text,
          'eqserial': _eqserialController.text,
          'eqstatus': _eqstatusController.text,
          'eqprice': _eqpriceController.text,
          'eqwarran': _eqwarranController.text,
          'eqbuydate':
              _eqbuydate != null
                  ? DateFormat('yyyy-MM-dd').format(_eqbuydate!)
                  : '',
          'eqdate':
              _eqdate != null ? DateFormat('yyyy-MM-dd').format(_eqdate!) : '',
        };
        if (_base64Image != null) {
          body['data'] = _base64Image!;
          body['name'] = _image!.path.split('/').last;
        }

        // Make the API call
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/insert_eq_new.php'),
            body: body,
          );

          if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);
            if (jsonResponse['success'] == 'true') {
              // Success!  (We'll show a single success message at the end)
            } else {
              // Show error message (for this specific insert attempt)
              _showDialog(
                context,
                "Error",
                "Failed to add item ${i + 1}: ${jsonResponse['error']}",
              );
              return; // Stop the loop on error.
            }
          } else {
            // Show error message for non-200 status code
            _showDialog(
              context,
              "Error",
              "Server error (item ${i + 1}): ${response.statusCode}",
            );
            return; // Stop the loop on server error.
          }
        } catch (e) {
          // Show error message for network or other exceptions
          _showDialog(context, "Error", "Exception (item ${i + 1}): $e");
          return; // Stop the loop on exception
        }
      }
      //If loop complete show success message
      _showDialog(
        context,
        "Success",
        "$quantity Equipment added successfully!",
      );
      _clearForm(); // Clear the form after successful submission
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Clear form
  void _clearForm() {
    _formKey.currentState!.reset();
    _eqtnameController.clear();
    _useridController.clear();
    _eqnameController.clear();
    _eqmodelController.clear();
    _eqbrandController.clear();
    _eqserialController.clear();
    _eqstatusController.clear();
    _eqpriceController.clear();
    _eqwarranController.clear();
    _quantityController.text = '1'; // Reset quantity to 1
    setState(() {
      _eqbuydate = null;
      _eqdate = null;
      _image = null;
      _base64Image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Equipment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // eq_type
              TextFormField(
                controller: _eqtnameController,
                decoration: InputDecoration(labelText: 'Equipment Type'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter equipment type' : null,
              ),
              // eq_serial (HN_id part)
              TextFormField(
                controller: _eqserialController,
                decoration: InputDecoration(labelText: 'Serial Number (XXX)'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter serial number' : null,
              ),
              // user_name
              TextFormField(
                controller: _useridController,
                decoration: InputDecoration(labelText: 'User Name'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter user name' : null,
              ),
              // eq_name
              TextFormField(
                controller: _eqnameController,
                decoration: InputDecoration(labelText: 'Equipment Name'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter equipment name' : null,
              ),
              // eq_brand
              TextFormField(
                controller: _eqbrandController,
                decoration: InputDecoration(labelText: 'Brand'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter brand' : null,
              ),
              // eq_model
              TextFormField(
                controller: _eqmodelController,
                decoration: InputDecoration(labelText: 'Model'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter model' : null,
              ),

              // eq_status
              TextFormField(
                controller: _eqstatusController,
                decoration: InputDecoration(labelText: 'Status'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter status' : null,
              ),
              // eq_price
              TextFormField(
                controller: _eqpriceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              // eq_buydate
              ListTile(
                title: Text(
                  'Buy Date: ${_eqbuydate != null ? DateFormat('yyyy-MM-dd').format(_eqbuydate!) : 'Select Date'}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              // eq_date
              ListTile(
                title: Text(
                  'Issue Date: ${_eqdate != null ? DateFormat('yyyy-MM-dd').format(_eqdate!) : 'Select Date'}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),

              // eq_warran
              TextFormField(
                controller: _eqwarranController,
                decoration: InputDecoration(labelText: 'Warranty'),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Please enter warranty information'
                            : null,
              ),
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              // eq_img
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Pick Image from Gallery'),
              ),

              if (_image != null) ...[
                SizedBox(height: 10),
                Image.file(_image!, height: 150),
              ],

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Equipment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _eqtnameController.dispose();
    _useridController.dispose();
    _eqnameController.dispose();
    _eqmodelController.dispose();
    _eqbrandController.dispose();
    _eqserialController.dispose();
    _eqstatusController.dispose();
    _eqpriceController.dispose();
    _eqwarranController.dispose();
    _quantityController.dispose(); // Dispose of the quantity controller
    super.dispose();
  }
}
