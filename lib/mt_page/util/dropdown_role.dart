import 'dart:convert';

List<DropdownRoleModel> dropdownRoleModelFromJson(String str) =>
    List<DropdownRoleModel>.from(
        json.decode(str).map((x) => DropdownRoleModel.fromJson(x)));

String dropdownRoleModelToJson(List<DropdownRoleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropdownRoleModel {
  String role_id;
  String role;

  DropdownRoleModel({
    required this.role_id,
    required this.role,
  });

  factory DropdownRoleModel.fromJson(Map<String, dynamic> json) =>
      DropdownRoleModel(
        role_id: json["role_id"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "mttype_id": role_id,
        "mttype_name": role,
      };
}
