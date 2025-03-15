import 'package:ems_condb/util/color.dart';
import 'package:ems_condb/util/font.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class buildMTPieChart extends StatelessWidget {
  final String title;
  final String type;
  final String type2;
  final List<PieChartSectionData> pieMTSections;
  const buildMTPieChart({
    super.key,
    required this.title,
    required this.type,
    required this.type2,
    required this.pieMTSections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: Fonts.Fontnormal.fontFamily,
            ),
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: PieChart(
                  PieChartData(
                    sections: pieMTSections,
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (pieMTSections.isNotEmpty) ...[
                    // Check if _pieEQSections is not empty
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildPieChartLegend(
                          type,
                          AppColors.mtchartColors[0],
                          '${pieMTSections[0].value.toInt().toString()}%', // Show the actual count
                        ),
                      ],
                    ),
                    _buildPieChartLegend(
                      type2,
                      AppColors.mtchartColors[1],
                      '${pieMTSections[1].value.toInt().toString()}%', // Show the actual count
                    ),
                  ] else ...[
                    // If _pieEQSections is empty, show a placeholder
                    Center(
                      child: Text(
                        'ไม่มีข้อมูล',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(String title, Color color, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: Fonts.Fontnormal.fontFamily,
                ),
              ), // Set font family to Kanit
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: Fonts.Fontnormal.fontFamily,
                ),
              ), // Set font family to Kanit
            ],
          ),
        ],
      ),
    );
  }
}
