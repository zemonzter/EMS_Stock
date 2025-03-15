// To parse this JSON data, do
//
//     final dropdownModel = dropdownModelFromJson(jsonString);

import 'dart:convert';

List<DropdownModel> dropdownModelFromJson(String str) =>
    List<DropdownModel>.from(
        json.decode(str).map((x) => DropdownModel.fromJson(x)));

String dropdownModelToJson(List<DropdownModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropdownModel {
  String eqtId;
  String eqtName;

  DropdownModel({
    required this.eqtId,
    required this.eqtName,
  });

  factory DropdownModel.fromJson(Map<String, dynamic> json) => DropdownModel(
        eqtId: json["eqt_id"],
        eqtName: json["eqt_name"],
      );

  Map<String, dynamic> toJson() => {
        "eqt_id": eqtId,
        "eqt_name": eqtName,
      };
}
