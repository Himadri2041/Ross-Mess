import 'package:flutter/material.dart';
import 'package:ross_mess_app/Screens/Admin/bill_page.dart';
import 'package:ross_mess_app/Screens/Admin/extras_upload_page.dart';
import 'package:ross_mess_app/Screens/Admin/attendance.dart';
import '../../Appcolors.dart';
import 'menu_upload_page.dart';
import 'order_page.dart';
import 'package:ross_mess_app/Screens/Admin/Widgets/action_button.dart';
import 'package:ross_mess_app/Screens/Admin/Widgets/sidebar.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                // Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Admin Panel",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Chakra_Petch',
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Admin",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.yellow,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        AdminActionButton(
                          icon: Icons.receipt_long,
                          label: "View Orders",
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => AdminOrders())),
                        ),
                        AdminActionButton(
                          icon: Icons.currency_rupee,
                          label: "Bill",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TotalBillScreen())),
                        ),
                        AdminActionButton(
                          icon: Icons.check_circle,
                          label: "Mark Attendance",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SelectMealScreen())),
                        ),
                        AdminActionButton(
                          icon: Icons.upload,
                          label: "Upload Menu",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MenuUploadScreen())),
                        ),
                        AdminActionButton(
                          icon: Icons.fastfood,
                          label: "Add Extras",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdminOrderScreen())),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
