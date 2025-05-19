import 'package:flutter/material.dart';
import 'package:ross_mess_app/Screens/Admin/bill_page.dart';
import 'package:ross_mess_app/Screens/Admin/extras_upload_page.dart';
import 'package:ross_mess_app/Screens/Admin/meals.dart';
import '../../Appcolors.dart';
import 'menu_upload_page.dart';
import 'order_page.dart';


class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: MessColors.test,
          centerTitle: false,
          title: Text("Admin Panel",style: TextStyle(color: Colors.white,fontFamily:'Chakra_Petch',fontWeight: FontWeight.w900),)),
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
              child: Text("bill"),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) =>TotalBillScreen())),
            ),
            ElevatedButton(
              child: Text("Upload Menu"),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MenuUploadScreen())),
            ),
            ElevatedButton(
              child: Text("Mark Attendance"),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => (MarkAttendanceScreen()))),
            ),
          ],
        ),
      ),
    );
  }
}
