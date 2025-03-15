import 'package:ems_condb/util/color.dart';
import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/months.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class buildPieChart extends StatelessWidget {
  final String title;
  final List<PieChartSectionData> pieSections;
  final List<String> months;
  const buildPieChart({
    super.key,
    required this.title,
    required this.pieSections,
    required this.months,
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
              fontFamily:
                  Fonts.Fontnormal.fontFamily, // Set font family to Kanit
            ),
          ),
          SizedBox(height: 8),
          Stack(
            // alignment: Alignment.centerRight,
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: PieChart(
                  PieChartData(
                    sections: pieSections,
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              SizedBox(width: 20),
              LayoutBuilder(
                // เพิ่ม LayoutBuilder เพื่อตรวจสอบขนาดหน้าจอ
                builder: (context, constraints) {
                  bool isMobile =
                      constraints.maxWidth <
                      600; // กำหนดให้ขนาดหน้าจอ < 600 เป็นมือถือ

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (months.length <= 6) // แสดงคอลัมน์เดียว
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < months.length; i++)
                              _buildPieChartLegend(
                                isMobile
                                    ? MonthNames.getThaiMonthName(
                                      MonthNames.getThaiMonthName(months[i]),
                                    )
                                    : MonthNames.getThaiFullMonthName(
                                      MonthNames.getThaiFullMonthName(
                                        months[i],
                                      ),
                                    ),
                                AppColors.chartColors[i %
                                    AppColors.chartColors.length],
                                '${(pieSections[i].value * 100).toInt()}%',
                              ),
                          ],
                        )
                      else // แสดงสองคอลัมน์
                      ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < (months.length / 2).ceil(); i++)
                              if (i < months.length)
                                _buildPieChartLegend(
                                  isMobile
                                      ? MonthNames.getThaiMonthName(
                                        MonthNames.getThaiMonthName(months[i]),
                                      )
                                      : MonthNames.getThaiFullMonthName(
                                        MonthNames.getThaiFullMonthName(
                                          months[i],
                                        ),
                                      ),
                                  AppColors.chartColors[i %
                                      AppColors.chartColors.length],
                                  '${(pieSections[i].value * 100).toInt()}%',
                                ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (
                              int i = (months.length / 2).ceil();
                              i < months.length;
                              i++
                            )
                              _buildPieChartLegend(
                                isMobile
                                    ? MonthNames.getShortMonthName(
                                      MonthNames.getMonthIndexFromShortName(
                                        months[i],
                                      ),
                                    )
                                    : MonthNames.getFullMonthName(
                                      MonthNames.getMonthIndexFromShortName(
                                        months[i],
                                      ),
                                    ),
                                AppColors.chartColors[i %
                                    AppColors.chartColors.length],
                                '${(pieSections[i].value * 100).toInt()}%',
                              ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),

              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     for (int i = 0; i < months.length; i++)
              //       _buildPieChartLegend(
              //         MonthNames.getFullMonthName(
              //           MonthNames.getMonthIndexFromShortName(months[i]),
              //         ),
              //         AppColors.chartColors[i % AppColors.chartColors.length],
              //         '${(pieSections[i].value * 100).toInt()}%',
              //       ),
              //   ],
              // ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPieChartLegend(String title, Color color, String subtitle) {
    return Wrap(
      children: [
        Padding(
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
                    style: TextStyle(color: Colors.grey, fontFamily: 'Kanit'),
                  ), // Set font family to Kanit
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
