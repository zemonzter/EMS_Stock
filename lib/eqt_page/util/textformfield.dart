import 'package:flutter/material.dart';

class Textformfield extends StatefulWidget {
  final String fieldname;
  final String? controller;
  const Textformfield({super.key, required this.fieldname, this.controller});

  @override
  State<Textformfield> createState() => _TextformfieldState();
}

class _TextformfieldState extends State<Textformfield> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            label: Text(widget.fieldname),
          ),
        )
      ],
    );
  }
}
