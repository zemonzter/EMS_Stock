import 'dart:convert';

List<DropdownMttypeModel> dropdownMttypeModelFromJson(String str) =>
    List<DropdownMttypeModel>.from(
        json.decode(str).map((x) => DropdownMttypeModel.fromJson(x)));

String dropdownMttypeModelToJson(List<DropdownMttypeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropdownMttypeModel {
  String mttypeId;
  String mttypeName;

  DropdownMttypeModel({
    required this.mttypeId,
    required this.mttypeName,
  });

  factory DropdownMttypeModel.fromJson(Map<String, dynamic> json) =>
      DropdownMttypeModel(
        mttypeId: json["mttype_id"],
        mttypeName: json["mttype_name"],
      );

  Map<String, dynamic> toJson() => {
        "mttype_id": mttypeId,
        "mttype_name": mttypeName,
      };
}
