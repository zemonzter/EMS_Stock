import 'dart:convert';

List<DropdownUnitModel> DropdownUnitModelFromJson(String str) =>
    List<DropdownUnitModel>.from(
        json.decode(str).map((x) => DropdownUnitModel.fromJson(x)));

String DropdownUnitModelToJson(List<DropdownUnitModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropdownUnitModel {
  String unitId;
  String unitName;

  DropdownUnitModel({
    required this.unitId,
    required this.unitName,
  });

  factory DropdownUnitModel.fromJson(Map<String, dynamic> json) =>
      DropdownUnitModel(
        unitId: json["unit_id"],
        unitName: json["unit_name"],
      );

  Map<String, dynamic> toJson() => {
        "unit_id": unitId,
        "unit_name": unitName,
      };
}
