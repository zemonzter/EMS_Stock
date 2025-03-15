import 'package:ems_condb/mainten_page/util/fullscreen_img.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowMaintenDetail extends StatelessWidget {
  final String id;
  final String hn;
  final String name;
  final String date;
  final String detail;
  final String user;
  final String status;
  final String img;
  const ShowMaintenDetail({
    super.key,
    required this.id,
    required this.name,
    required this.date,
    required this.detail,
    required this.user,
    required this.status,
    required this.img,
    required this.hn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$name',
          style: TextStyle(fontFamily: GoogleFonts.mali().fontFamily),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                // width: Responsive.isDesktop(context) ? 1000 : double.infinity,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เลขแจ้งซ่อม: $id',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      Text(
                        'เลขครุภัณฑ์: $hn',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      Text(
                        'ชื่อครุภัณฑ์: $name',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      Text(
                        'รายละเอียด: $detail',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      Text(
                        'วันที่แจ้ง: $date',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      Text(
                        'ผู้แจ้ง: $user',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),
                      Text(
                        'สถานะ: $status',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: GoogleFonts.mali().fontFamily,
                        ),
                      ),

                      const SizedBox(height: 16.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: InkWell(
                          // Wrap with InkWell for tap functionality
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FullScreenImage(
                                      imageUrl: img,
                                    ), // Pass the image URL
                              ),
                            );
                          },
                          child: Image.network(
                            img,
                            width:
                                MediaQuery.of(context).size.width > 1000
                                    ? 600
                                    : 1000, // Limit width
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) => Image.asset(
                                  'assets/images/default.jpg', // Show default image on error
                                  fit: BoxFit.contain,
                                ),
                            loadingBuilder: (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child; // Return the image itself when loading is complete
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
