import 'package:flutter/rendering.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationSender {
  static const _serviceAccount = {
    "project_id": "mews-project",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDWwJQaj7cNYI2J\ncozYWiBVxzu8CN9RoBJ4xaECpNu3ehAWcTf3mNin0+qnE2vzxU6skkN+RmCjVHJK\ngD2KMiyntVNz0ybcoLjNp2nVOFBhWTMrd+tZbkgp0Vbb8dh1a331sW+rE0M4yHnY\ndPjcF9SpTnv56IoGePwg6Iy+rzYSHFveTDGawXV/IxmeSoXUWgIh8HFMLAoPgkZB\n4qSABwqQL2VAJLV4CzcJYzXiPWvbhOz5VWmpIS8oAU/0V64W4Xa9kfBLz7um4LOU\naelGX+6r1/sQ7DY/18Ikq/X9U2FN6hjOR0q2IGKfKAKEk9i/I2LrjzznC4ELID0K\np+m/9RePAgMBAAECggEAMJY+i+njDPxA2Y2YryRo929NpQPO3s1cEIYKISqCaXcM\n577y3ipvLj1kdCuRO4RzAdlPuuSaXamv+AoeokMq1kDQoj5uJvGYDjNn3u1QRk4j\npRyLG183pXpu7/E+O4a351wfOzHu/gxhgOcqHMWpgCq5IvgJLmC2Do3+te+3SI5G\ntTzaZ/aqVagyWZdfQ5kgR9zZpmh8w2399mjPbjptzVV2nx2yU2Vs/AcFJ6AACAfO\n3JDrbJerUCM0/93HxjjiLuVeiFij112RN0bZNLjavdlDB6V6o95+w0e4MsjjSxGp\nxt5yESv+deuatORec+/ad7W/A+kBt+XOl/xOql/EcQKBgQD4ljymabK3RQPfS+mQ\n5VjZD6NNsqFqI/HgdHyZTXsTSi12ihYdiPFI7S3ZodqhLaezQjNc1HHrm2mvDHl2\nATex29Xmbd9/EsbWeuwztxiQ9lMS/asHT95VzyuF1J9xOk/NOJ01c89o51D/mPOv\n+66HER0TPoe3rlX2rID4UdBafwKBgQDdKAqT1gaHP7/5ukbn81/hJ0a7wyX3K99h\nFzPkG7ux8MGGfQHaTvq1QbMkmDYdgi1jxFg8tzYW7joMd34Xse2LmX72zWvX/cQH\nOrm5MVreJDlC1wz36DqAi/t/Dw3NSbQ68vQBUwcqFFiGNIbVdlGfRMC5ZanaqfKs\n9hZ1+OEa8QKBgDQxVwqZpqxUETwQ9Dk37i+k2OS3XKysX1yBGKgXXH/wUxtQYtRQ\nrFhjc/z9vqmYrF02yRH0iPau6sGWHOpp1wfA4GhBKWvExXrC1FUHXGETVt3l5MLk\nQgpCNSEkQ1XCqH6uJFPUvPeJmbgQpRmN/lbdgP1JY7VtJR9lmK6KfvSBAoGBALW8\nNMz9oMm9smVmFOSA03ZzTyX2nJk8HUlsxsCZpaj43h9FVKNwKYePoMXeqwGeuuv0\nKkpih/lZ9KvP+fdAyKLiFTp83jVVHKSQNpSfoTtQ6xkpHUgPNxvxbE8iMMZU3d1f\nTvJTp1yF8aT/PxnlK/fEiNcRWv4MkBZf918kkN8RAoGAKbY7F+Eow1Gk8Bw8ddFK\nLz8PLHgMecVkJZ/8ph+h+nF/Cul9Jq2NZCo6JukTxbFtrfeo3LF8Vx2u4I3tjRrR\nc8J73t3y5BbmBQ7+dbQ1NoUnwXGAFAzpqhtkOivuBExew92K+luStni5b7v3AbuX\nO0ORVhFHG6a2d2jenbQRA0Q=\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@mews-project.iam.gserviceaccount.com",
  };

  static Future<String> _getAccessToken() async {
    final credentials = auth.ServiceAccountCredentials.fromJson(_serviceAccount);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await auth.clientViaServiceAccount(credentials, scopes);
    return client.credentials.accessToken.data;
  }

  static Future<void> sendSelfAlarm({required String deviceToken, required String patientID, required String patientName, required DateTime alarmTime}) async {
    final accessToken = await _getAccessToken();
    final String projectId = _serviceAccount['project_id']!;

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
      body: jsonEncode({
        "message": {
          "token": deviceToken,
          "data": {"time": alarmTime.toIso8601String(), "patientID": patientID, "patientName": patientName},
          "apns": {
            "payload": {
              "aps": {"content-available": 1, "priority": 10},
            },
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      debugPrint("Production Notification Sent Successfully");
    } else {
      debugPrint("Failed to send: ${response.body}");
    }
  }
}
