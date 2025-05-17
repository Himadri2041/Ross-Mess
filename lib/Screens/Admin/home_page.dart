import 'package:flutter/material.dart';
import 'package:ross_mess_app/Screens/Admin/extras_upload_page.dart';
import 'menu_upload_page.dart';
import 'order_page.dart';


class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("View Orders"),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AdminOrders())),
            ),
            ElevatedButton(
              child: Text("Upload Menu"),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MenuUploadScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
