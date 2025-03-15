import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // เพิ่ม package google_fonts

class Fonts {
  static TextStyle Fontnormal =
      GoogleFonts.sarabun(); // เพิ่ม TextStyle สำหรับ font Sarabun
  static TextStyle FontBold = GoogleFonts.sarabun(
    fontWeight: FontWeight.bold,
  ); // เพิ่ม TextStyle สำหรับ font Sarabun แบบ Bold
  static TextStyle FontItalic = GoogleFonts.sarabun(
    fontStyle: FontStyle.italic,
  ); // เพิ่ม TextStyle สำหรับ font Sarabun แบบ Italic
  static TextStyle FontBoldItalic = GoogleFonts.sarabun(
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
  ); // เพิ่ม TextStyle สำหรับ font Sarabun แบบ Bold Italic
}
