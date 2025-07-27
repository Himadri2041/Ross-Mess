import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../fonts.dart';

class TotalBillScreen extends StatefulWidget {
  const TotalBillScreen({super.key});

  @override
  State<TotalBillScreen> createState() => _TotalBillScreenState();
}

class _TotalBillScreenState extends State<TotalBillScreen> {
  Map<String, double> studentBills = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  Future<void> fetchBills() async {
    final now = DateTime.now();
    final currentMonthPrefix = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final snapshot = await FirebaseFirestore.instance.collection('attendance').get();
    Map<String, double> bills = {};

    for (var doc in snapshot.docs) {
      final docId = doc.id;
      if (!docId.startsWith(currentMonthPrefix)) continue;

      final dateData = doc.data();

      for (var roll in dateData.keys) {
        final studentMealsRaw = dateData[roll];
        if (studentMealsRaw is Map<String, dynamic>) {
          final studentMeals = studentMealsRaw;

          for (var meal in studentMeals.keys) {
            final mealDataRaw = studentMeals[meal];
            if (mealDataRaw is Map<String, dynamic>) {
              // Add meal price if meal was taken
              if (mealDataRaw.containsKey('price')) {
                double mealPrice = (mealDataRaw['price'] ?? 0).toDouble();
                bills[roll] = (bills[roll] ?? 0) + mealPrice;
              }

              // Add extras price
              if (mealDataRaw.containsKey('extras')) {
                final extras = mealDataRaw['extras'];
                if (extras is List) {
                  for (var extra in extras) {
                    double price = (extra['price'] ?? 0).toDouble();
                    bills[roll] = (bills[roll] ?? 0) + price;
                  }
                }
              }
            }
          }
        }
      }
    }

    setState(() {
      studentBills = bills;
      isLoading = false;
    });
  }


  Future<void> exportAndDeleteLastMonth() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthPrefix = "${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}";

    final snapshot = await FirebaseFirestore.instance.collection('attendance').get();
    Map<String, double> bills = {};

    for (var doc in snapshot.docs) {
      final docId = doc.id;
      if (!docId.startsWith(lastMonthPrefix)) continue;

      final dateData = doc.data();

      for (var roll in dateData.keys) {
        final studentMealsRaw = dateData[roll];
        if (studentMealsRaw is Map<String, dynamic>) {
          final studentMeals = studentMealsRaw;

          for (var meal in studentMeals.keys) {
            final mealDataRaw = studentMeals[meal];
            if (mealDataRaw is Map<String, dynamic>) {
              if (mealDataRaw.containsKey('extras')) {
                final extras = mealDataRaw['extras'];
                if (extras is List) {
                  for (var extra in extras) {
                    double price = (extra['price'] ?? 0).toDouble();
                    bills[roll] = (bills[roll] ?? 0) + price;
                  }
                }
              }
            }
          }
        }
      }
    }

    if (bills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No last month bills to export or delete.")),
      );
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Bills'];
    sheet.appendRow(["Roll Number", "Total Bill (₹)"]);
    bills.forEach((roll, total) {
      sheet.appendRow([roll, total]);
    });

    final dir = await getExternalStorageDirectory();
    final path = "${dir!.path}/student_bills_${lastMonthPrefix}.xlsx";
    final fileBytes = excel.encode();
    final file = File(path)..createSync(recursive: true)..writeAsBytesSync(fileBytes!);
    await OpenFile.open(file.path);

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Do you want to delete last month's data ($lastMonthPrefix) from Firestore after exporting?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      for (var doc in snapshot.docs) {
        if (doc.id.startsWith(lastMonthPrefix)) {
          await FirebaseFirestore.instance.collection('attendance').doc(doc.id).delete();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Deleted last month's data from Firestore.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Deletion canceled.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Total Bill Report", style: AppFonts.title.copyWith(letterSpacing: 0.5)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentBills.isEmpty
          ? const Center(child: Text("No bills found"))
          : ListView.builder(
        itemCount: studentBills.length,
        itemBuilder: (context, index) {
          final roll = studentBills.keys.elementAt(index);
          final bill = studentBills[roll]!;
          return ListTile(
            title: Text("Roll: $roll"),
            trailing: Text("₹${bill.toStringAsFixed(2)}"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: exportAndDeleteLastMonth,
        icon: const Icon(Icons.download),
        label: const Text("Export + Delete Last Month"),
      ),
    );
  }
}
