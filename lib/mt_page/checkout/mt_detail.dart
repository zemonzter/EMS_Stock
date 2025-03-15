import 'dart:convert';

import 'package:ems_condb/api_config.dart';
import 'package:http/http.dart' as http;

class MaterialDetails {
  final int mtId;
  final int currentStock;

  MaterialDetails({required this.mtId, required this.currentStock});
}

Future<MaterialDetails?> _fetchMaterialDetails(int mtId) async {
  String mtDetailsUrl = "${baseUrl}view_mt.php"; // Corrected endpoint
  try {
    var mtResponse = await http.post(
      Uri.parse(mtDetailsUrl),
      body: {'mt_id': mtId.toString()},
    );

    if (mtResponse.statusCode == 200 && mtResponse.body.isNotEmpty) {
      final mtData = jsonDecode(mtResponse.body);
      if (mtData is Map<String, dynamic>) {
        final int currentStock =
            int.tryParse(mtData['mt_stock']?.toString() ?? '') ?? 0;

        if (currentStock == 0) {
          // print("Error parsing mt details: mt_stock is zero or null.");
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //         "Error parsing material details (mt_stock is zero or null)."),
          //   ),
          // );
          // return null;
        }
        return MaterialDetails(mtId: mtId, currentStock: currentStock);
      } else {
        // print("Unexpected response format for mt details: $mtData");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Unexpected response format for mt details")),
        // );
        return null;
      }
    } else {
      //  print("Error fetching mt details or empty response: ${mtResponse.statusCode}");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content:
      //           Text("Error fetching mt details: ${mtResponse.statusCode}")),
      // );
      return null;
    }
  } catch (e) {
    // print("Exception fetching material details: $e");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Error fetching material details: $e")),
    // );
    return null;
  }
}
