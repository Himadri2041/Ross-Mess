import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String serverKey = 'YOUR_SERVER_KEY';

  Future<void> sendNotificationToToken(String token, String title, String body) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        "to": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "priority": "high",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send notification: ${response.body}");
    }
  }
}
