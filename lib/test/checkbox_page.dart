import 'package:flutter/material.dart';

class CenterCheckboxPage extends StatefulWidget {
  const CenterCheckboxPage({super.key});

  @override
  _CenterCheckboxPageState createState() => _CenterCheckboxPageState();
}

class _CenterCheckboxPageState extends State<CenterCheckboxPage> {
  bool _isChecked = false; // ตัวแปรเก็บสถานะ checkbox

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkbox ตรงกลาง')),
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // ทำให้ Column มีขนาดเล็กที่สุดเท่าที่จะทำได้
          children: <Widget>[
            Checkbox(
              value: _isChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  _isChecked = newValue!;
                });
              },
            ),
            SizedBox(height: 10), // เพิ่มระยะห่างระหว่าง Checkbox และ Text
            Text(
              _isChecked
                  ? 'เลือกแล้ว'
                  : 'ยังไม่ได้เลือก', // แสดงข้อความตามสถานะ checkbox
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
