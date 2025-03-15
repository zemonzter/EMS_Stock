import 'package:ems_condb/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlockDetail extends StatelessWidget {
  final String blockName;
  final String blockImage; // Made blockImage nullable
  final VoidCallback? onTap; // Added onTap callback

  const BlockDetail({
    super.key,
    required this.blockName,
    required this.blockImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double containerWidth = 165;
    double containerHeight = 221;
    double avatarRadius = 75;
    double fontSize = 14;
    double paddingValue = 8.0;
    double sizedBoxHeight = 20;
    double redHeight = containerHeight / 4.5;

    if (Responsive.isTablet(context)) {
      containerWidth = 190; // Larger width for tablets
      containerHeight = 240; // Larger height for tablets
      avatarRadius = 70; // Larger avatar radius
      fontSize = 18; // Larger font size
      paddingValue = 10.0; // More padding
      sizedBoxHeight = 30;
      redHeight = containerHeight / 4.5;
    } else if (Responsive.isDesktop(context)) {
      containerWidth = 210; // Even larger width for desktops
      containerHeight = 270; // Even larger height for desktops
      avatarRadius = 80; // Even Larger avatar
      fontSize = 20;
      paddingValue = 10.0;
      sizedBoxHeight = 40;
      redHeight = containerHeight / 5;
    }
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                  color: Color.fromRGBO(240, 240, 240, 1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Column(
                children: [
                  SizedBox(height: sizedBoxHeight),
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: NetworkImage(blockImage),
                  ),
                  SizedBox(height: sizedBoxHeight),
                  Container(
                    width: containerWidth,
                    height: redHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(125, 1, 1, 1),
                      borderRadius: BorderRadius.only(
                        // topLeft: Radius.circular(0),
                        // topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Text(
                      blockName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontFamily: GoogleFonts.mali().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
