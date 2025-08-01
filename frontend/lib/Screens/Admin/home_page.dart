import 'package:flutter/material.dart';
import 'package:ross_mess_app/Screens/Admin/bill_page.dart';
import 'package:ross_mess_app/Screens/Admin/extras_upload_page.dart';
import 'package:ross_mess_app/Screens/Admin/attendance.dart';
import 'package:ross_mess_app/Screens/Admin/image_upload.dart';
import 'package:ross_mess_app/Screens/Admin/notify_users.dart';
import 'package:ross_mess_app/Screens/Admin/order_ready.dart';
import 'package:ross_mess_app/Screens/Admin/update_quantity.dart';
import '../../Appcolors.dart';
import 'menu_upload_page.dart';
import 'order_page.dart';
import 'package:ross_mess_app/Screens/Admin/Widgets/action_button.dart';


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
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lora',
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Admin",
                          style: TextStyle(fontWeight: FontWeight.w700,fontFamily:
                          'DMS'),
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
                          icon: Icons.upload,
                          label: "Upload Menu",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MenuUploadScreen())),
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
                          icon: Icons.receipt_long,
                          label: "View Orders",
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => AdminOrders())),
                        ),
                        AdminActionButton(
                          icon: Icons.done_all,
                          label: "Orders done",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ReadyOrders())),
                        ),

                        AdminActionButton(
                          icon: Icons.fastfood,
                          label: "Add Extras",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdminOrderScreen())),
                        ),
                        AdminActionButton(
                          icon: Icons.image,
                          label: "Upload Images",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => UniversalImageUploader())),
                        ),
                        AdminActionButton(
                          icon: Icons.update,
                          label: "Update extras",
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdminInventoryScreen())),
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
                          icon: Icons.receipt_long,
                          label: "Notifications",
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => SendNotificationPage())),
                        )

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
