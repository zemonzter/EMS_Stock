import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowDetail extends StatelessWidget {
  final String id;
  final String brand;
  final String name;
  final String image;
  final String user;
  final String type;
  final String price;
  final String status;
  final String date;
  final String warranty;

  const ShowDetail({
    super.key,
    required this.id,
    required this.brand,
    required this.name,
    required this.image,
    required this.user,
    required this.type,
    required this.price,
    required this.status,
    required this.date,
    required this.warranty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$brand  $name',
          style: TextStyle(
            fontSize: Responsive.isDesktop(context) ? 26.0 : 22.0,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.mali().fontFamily,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: Responsive.isDesktop(context) ? 1000 : double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      image,
                      width:
                          MediaQuery.of(context).size.width > 1000 ? 600 : 1000,
                      height: 350,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '$brand  $name',
                  style: TextStyle(
                    fontSize: Responsive.isDesktop(context) ? 26.0 : 22.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.mali().fontFamily,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ประเภทครุภัณฑ์: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: type,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'เลขครุภัณฑ์: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: id,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ยี่ห้อ: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: brand,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'รุ่น: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: name,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ราคา: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'วันที่ซื้อ: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: date,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ระยะเวลาการรับประกัน: ',
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: warranty,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'สถานะ: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: status,
                        style: TextStyle(
                          color: status == 'Inactive' ? Colors.red : null,
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ผู้ถือครอง: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.isDesktop(context) ? 24.0 : 18.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      TextSpan(
                        text: user,
                        style: TextStyle(
                          fontSize: Responsive.isDesktop(context) ? 22.0 : 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
