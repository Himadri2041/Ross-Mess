import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendNotificationPage extends StatefulWidget {
  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _isSending = false;
  String? _statusMessage;

  Future<void> sendNotification() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      setState(() {
        _statusMessage = "Please fill in both title and body.";
      });
      return;
    }

    setState(() {
      _isSending = true;
      _statusMessage = null;
    });

    try {
      // Replace with your backend URL
      final url = Uri.parse("http://192.168.1.180:3000/notify-custom-message");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "title": title,
          "body": body,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "✅ Notification sent successfully!";
        });
      } else {
        setState(() {
          _statusMessage = "❌ Failed: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "⚠️ Error: $e";
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: const Text("Send Notification"),
        backgroundColor: Colors.amber[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Notification Title",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.amber[100],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: "Notification Body",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.amber[100],
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isSending ? null : sendNotification,
                icon: const Icon(Icons.send, color: Colors.black),
                label: _isSending
                    ? const Text("Sending...", style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600))
                    : const Text("Send Notification", style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[500],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith("✅")
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}