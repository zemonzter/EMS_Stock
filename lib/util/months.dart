class MonthNames {
  static const List<String> fullMonthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  static const Map<String, int> shortMonthToIndex = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "May": 5,
    "Jun": 6,
    "Jul": 7,
    "Aug": 8,
    "Sep": 9,
    "Oct": 10,
    "Nov": 11,
    "Dec": 12,
    "ม.ค.": 1,
    "ก.พ.": 2,
    "มี.ค.": 3,
    "เม.ย.": 4,
    "พ.ค.": 5,
    "มิ.ย.": 6,
    "ก.ค.": 7,
    "ส.ค.": 8,
    "ก.ย.": 9,
    "ต.ค.": 10,
    "พ.ย.": 11,
    "ธ.ค.": 12,
  };

  static const List<String> shortMonthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  static String getFullMonthName(int monthIndex) {
    if (monthIndex >= 1 && monthIndex <= 12) {
      return fullMonthNames[monthIndex - 1];
    } else {
      return "Invalid Month"; // Handle invalid input
    }
  }

  static int getMonthIndexFromShortName(String shortName) {
    return shortMonthToIndex[shortName] ?? -1; // -1 if not found
  }

  static String getShortMonthName(int monthIndex) {
    if (monthIndex >= 1 && monthIndex <= 12) {
      return shortMonthNames[monthIndex - 1];
    } else {
      return "Invalid Month";
    }
  }
}
