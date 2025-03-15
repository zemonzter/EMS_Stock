import 'package:ems_condb/util/font.dart';
import 'package:ems_condb/util/responsive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../util/months.dart';

class buildBarChart extends StatefulWidget {
  final String title;
  final List<BarChartGroupData> barGroups;
  final List<String> months;

  const buildBarChart({
    super.key,
    required this.title,
    required this.barGroups,
    required this.months,
  });

  @override
  State<buildBarChart> createState() => _buildBarChartState();
}

class _buildBarChartState extends State<buildBarChart> {
  String? selectedStartYear;
  String? selectedStartMonth;
  String? selectedEndYear;
  String? selectedEndMonth;

  List<BarChartGroupData> _filteredBarGroups = [];

  @override
  void initState() {
    super.initState();
    _filteredBarGroups = widget.barGroups;
  }

  int _getMonthIndex(String monthName) {
    return widget.months.indexOf(monthName);
  }

  List<BarChartGroupData> _filterBarGroups(
    List<BarChartGroupData> originalBarGroups,
    String? startYear,
    String? startMonth,
    String? endYear,
    String? endMonth,
  ) {
    if (startYear == null &&
        startMonth == null &&
        endYear == null &&
        endMonth == null) {
      return originalBarGroups;
    }

    List<BarChartGroupData> filteredGroups = [];

    for (int i = 0; i < originalBarGroups.length; i++) {
      final group = originalBarGroups[i];
      // final String currentMonth = widget.months[i]; // "Jan", "Feb", etc.  // Not needed
      bool includeGroup = false;

      // Determine the year of the current bar group.  We assume your bar groups are sorted chronologically.
      int barGroupYear = -1; // Initialize to an invalid year.
      List<String> years = ["2025", "2024", "2023"]; // Your available years.
      for (int y = 0; y < years.length; y++) {
        int yearStartIndex =
            y * 12; // Jan of 2025 is index 0, Jan of 2022 is index 12, etc.
        if (i >= yearStartIndex && i < yearStartIndex + 12) {
          barGroupYear = int.parse(years[y]);
          break;
        }
      }
      if (barGroupYear == -1)
        continue; // Skip this group if we couldn't determine the year

      DateTime barGroupDate = DateTime(
        barGroupYear,
        i % 12 + 1,
      ); // +1 because month indices are 0-based.

      // --- Start Date Check ---
      if (startYear != null &&
          startYear != "ทั้งหมด" &&
          startMonth != null &&
          startMonth != "ทั้งหมด") {
        DateTime startDate = DateTime(
          int.parse(startYear),
          _getMonthIndex(startMonth) + 1,
        );
        if (barGroupDate.isAfter(startDate) ||
            barGroupDate.isAtSameMomentAs(startDate)) {
          includeGroup = true;
        } else {
          includeGroup = false; // Before the start date.
        }
      } else if (startYear != null && startYear != "ทั้งหมด") {
        // only year select
        DateTime startDate = DateTime(
          int.parse(startYear),
          1,
        ); // compare from Jan
        if (barGroupDate.isAfter(startDate) ||
            barGroupDate.isAtSameMomentAs(startDate)) {
          includeGroup = true;
        } else {
          includeGroup = false;
        }
      } else {
        includeGroup = true; // No start date specified, so potentially include.
      }

      // --- End Date Check ---  (Only check if it passed the start date check)

      if (includeGroup &&
          endYear != null &&
          endYear != "ทั้งหมด" &&
          endMonth != null &&
          endMonth != "ทั้งหมด") {
        DateTime endDate = DateTime(
          int.parse(endYear),
          _getMonthIndex(endMonth) + 1,
        );
        if (barGroupDate.isBefore(endDate) ||
            barGroupDate.isAtSameMomentAs(endDate)) {
          includeGroup = true; // Within start and end date.
        } else {
          includeGroup = false; // After the end date
        }
      } else if (includeGroup && endYear != null && endYear != "ทั้งหมด") {
        // only year select
        DateTime endDate = DateTime(
          int.parse(endYear),
          12,
        ); //compare with december
        if (barGroupDate.isBefore(endDate) ||
            barGroupDate.isAtSameMomentAs(endDate)) {
          includeGroup = true;
        } else {
          includeGroup = false; // After the end date
        }
      }
      // If includeGroup is still true after the end date check, it means it falls within the range.
      if (includeGroup) {
        filteredGroups.add(group);
      }
    }
    return filteredGroups;
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: Fonts.Fontnormal.fontFamily,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'เลือกแสดงข้อมูล',
                          style: TextStyle(
                            fontFamily: Fonts.Fontnormal.fontFamily,
                          ),
                        ),
                        content: StatefulBuilder(
                          builder: (context, setStateDialog) {
                            return Column(
                              // Changed from Row to Column
                              mainAxisSize: MainAxisSize.min, // Added this
                              children: [
                                // Start Year Dropdown
                                DropdownButton<String>(
                                  hint: Text(
                                    "เลือกปีที่ต้องการ",
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                  value: selectedStartYear,
                                  items:
                                      ["ทั้งหมด", "2025", "2024", "2023"]
                                          .map<DropdownMenuItem<String>>(
                                            (String value) =>
                                                DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Fonts
                                                              .Fontnormal
                                                              .fontFamily,
                                                    ),
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                  onChanged: (String? newValue) {
                                    setStateDialog(() {
                                      selectedStartYear = newValue;
                                      selectedStartMonth =
                                          null; // Reset month selection
                                      // _filteredBarGroups = _filterBarGroups(  // Removed parameters.  They are now class level.
                                      //   widget.barGroups,
                                      //   selectedStartYear,
                                      //   selectedEndYear,
                                      //   selectedStartMonth,
                                      //   selectedEndMonth,
                                      // );
                                    });
                                  },
                                ),
                                // End Year Dropdown
                                // DropdownButton<String>(
                                //   hint: Text(
                                //     "Select End Year",
                                //     style: TextStyle(fontFamily: Fonts.Fontnormal.fontFamily,),
                                //   ),
                                //   value: selectedEndYear,
                                //   items:
                                //       ["All", "2021", "2022", "2023", "2024"]
                                //           .map<DropdownMenuItem<String>>(
                                //             (String value) =>
                                //                 DropdownMenuItem<String>(
                                //                   value: value,
                                //                   child: Text(
                                //                     value,
                                //                     style: TextStyle(
                                //                       fontFamily: Fonts.Fontnormal.fontFamily,
                                //                     ),
                                //                   ),
                                //                 ),
                                //           )
                                //           .toList(),
                                //   onChanged: (String? newValue) {
                                //     setStateDialog(() {
                                //       selectedEndYear = newValue;
                                //       selectedEndMonth =
                                //           null; // Reset month selection
                                //       // _filteredBarGroups = _filterBarGroups(
                                //       //   widget.barGroups,
                                //       //   selectedStartYear,
                                //       //   selectedEndYear,
                                //       //   selectedStartMonth,
                                //       //   selectedEndMonth,
                                //       // );
                                //     });
                                //   },
                                // ),
                                // Start Month Dropdown
                                DropdownButton<String>(
                                  hint: Text(
                                    "เลือกเดือนเริ่มต้น",
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                  value: selectedStartMonth,
                                  items:
                                      [
                                            Responsive.isMobile(context)
                                                ? "ทั้งหมด"
                                                : "ทั้งหมด", // Add "ทั้งหมด" conditionally
                                            ...widget.months
                                                .map(
                                                  (englishMonth) =>
                                                      Responsive.isMobile(
                                                            context,
                                                          )
                                                          ? MonthNames.getThaiMonthName(
                                                            englishMonth,
                                                          ) // Short name for mobile
                                                          : MonthNames.getThaiFullMonthName(
                                                            englishMonth,
                                                          ), // Full name for other screens
                                                )
                                                .toList(),
                                          ]
                                          .map<DropdownMenuItem<String>>(
                                            (String value) =>
                                                DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Fonts
                                                              .Fontnormal
                                                              .fontFamily,
                                                    ),
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                  onChanged: (String? newValue) {
                                    setStateDialog(() {
                                      selectedStartMonth = newValue;
                                      // _filteredBarGroups = _filterBarGroups(
                                      //   widget.barGroups,
                                      //   selectedStartYear,
                                      //   selectedEndYear,
                                      //   selectedStartMonth,
                                      //   selectedEndMonth,
                                      // );
                                    });
                                  },
                                ),

                                // End Month Dropdown
                                DropdownButton<String>(
                                  hint: Text(
                                    "เลือกเดือนสิ้นสุด",
                                    style: TextStyle(
                                      fontFamily: Fonts.Fontnormal.fontFamily,
                                    ),
                                  ),
                                  value: selectedEndMonth,
                                  items:
                                      [
                                            "ทั้งหมด",
                                            ...widget.months
                                                .map(
                                                  (englishMonth) =>
                                                      MonthNames.getThaiFullMonthName(
                                                        englishMonth,
                                                      ),
                                                )
                                                .toList(),
                                          ]
                                          .map<DropdownMenuItem<String>>(
                                            (String value) =>
                                                DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          Fonts
                                                              .Fontnormal
                                                              .fontFamily,
                                                    ),
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                  onChanged: (String? newValue) {
                                    setStateDialog(() {
                                      selectedEndMonth = newValue;
                                      // _filteredBarGroups = _filterBarGroups(
                                      //   widget.barGroups,
                                      //   selectedStartYear,
                                      //   selectedEndYear,
                                      //   selectedStartMonth,
                                      //   selectedEndMonth,
                                      // );
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                // Apply filter
                                _filteredBarGroups = _filterBarGroups(
                                  widget.barGroups,
                                  selectedStartYear,
                                  selectedStartMonth,
                                  selectedEndYear,
                                  selectedEndMonth,
                                );
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'ตกลง',
                              style: TextStyle(
                                fontFamily: Fonts.Fontnormal.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.sort),
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: BarChart(
              BarChartData(
                barGroups: _filteredBarGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final int filteredIndex = value.toInt();
                        if (filteredIndex >= 0 &&
                            filteredIndex < _filteredBarGroups.length) {
                          int originalIndex = -1;

                          //Need to find the original index of the bar group, before filtering.
                          for (int i = 0; i < widget.barGroups.length; i++) {
                            if (_filteredBarGroups[filteredIndex] ==
                                widget.barGroups[i]) {
                              originalIndex = i;
                              break;
                            }
                          }

                          if (originalIndex != -1) {
                            String monthName = widget.months[originalIndex];
                            return Text(
                              Responsive.isMobile(context)
                                  ? MonthNames.getThaiMonthName(
                                    monthName,
                                  ) // Show short Thai month name
                                  : MonthNames.getThaiFullMonthName(
                                    monthName,
                                  ), // Show Thai month name
                            );
                          }
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 == 0) {
                          return Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              fontFamily: Fonts.Fontnormal.fontFamily,
                            ),
                          );
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: Fonts.Fontnormal.fontFamily,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
