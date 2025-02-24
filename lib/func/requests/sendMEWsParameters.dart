import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendMEWsValues({
  required String consciousness,
  required String? heart_rate, // Use nullable types
  required String? temperature,
  required String? systolic_bp,
  required String? spo2,
  required String? respiratory_rate,
  required String? urine,
}) async {
  String response = ''; // Declare response variable outside of try block

  try {
    var url = Uri.parse('https://pulse-fast-api.vercel.app/process-values/');

    var body = jsonEncode({
      'consciousness': consciousness,
      'heart_rate': heart_rate != null ? int.tryParse(heart_rate) : null,
      'temperature': temperature != null ? double.tryParse(temperature) : null,
      'systolic_bp': systolic_bp != null ? int.tryParse(systolic_bp) : null,
      'spo2': spo2 != null ? int.tryParse(spo2) : null,
      'respiratory_rate':
          respiratory_rate != null ? int.tryParse(respiratory_rate) : null,
      'urine': urine != null ? int.tryParse(urine) : null,
    });

    // Perform the POST request
    var httpResponse = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (httpResponse.statusCode == 200) {
      var mewsScore = jsonDecode(httpResponse.body)['mews_score'];
      response =
          'MEWS Score: $mewsScore'; // Update the response with the MEWS score
    } else {
      response = 'Error: ${httpResponse.statusCode} - ${httpResponse.body}';
    }
  } catch (e) {
    response = 'Error: $e';
  }

  return response;
}
