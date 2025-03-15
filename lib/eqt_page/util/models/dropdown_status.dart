// To parse this JSON data, do
//
//     final dropdownStatus = dropdownStatusFromJson(jsonString);

import 'dart:convert';

List<DropdownStatus> dropdownStatusFromJson(String str) =>
    List<DropdownStatus>.from(
        json.decode(str).map((x) => DropdownStatus.fromJson(x)));

String dropdownStatusToJson(List<DropdownStatus> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropdownStatus {
  String status_id;
  String status;

  DropdownStatus({
    required this.status_id,
    required this.status,
  });

  factory DropdownStatus.fromJson(Map<String, dynamic> json) => DropdownStatus(
        status_id: json["status_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status_id": status_id,
        "status": status,
      };
}
