import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
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
    final snapshot = await FirebaseFirestore.instance.collection('attendance').get();
    Map<String, double> bills = {};

    for (var doc in snapshot.docs) {
      Map<String, dynamic> dateData = doc.data();

      for (var roll in dateData.keys) {
        Map<String, dynamic> studentMeals = Map<String, dynamic>.from(dateData[roll]);

        for (var meal in studentMeals.keys) {
          Map<String, dynamic> mealData = Map<String, dynamic>.from(studentMeals[meal]);

          if (mealData.containsKey('extras')) {
            List extras = mealData['extras'];

            for (var extra in extras) {
              double price = (extra['price'] ?? 0).toDouble();
              bills[roll] = (bills[roll] ?? 0) + price;
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

  Future<void> exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Bills'];

    sheet.appendRow(["Roll Number", "Total Bill (₹)"]);

    studentBills.forEach((roll, total) {
      sheet.appendRow([roll, total]);
    });

    final dir = await getExternalStorageDirectory();
    final path = "${dir!.path}/student_bills.xlsx";

    final fileBytes = excel.encode();
    final file = File(path)..createSync(recursive: true)..writeAsBytesSync(fileBytes!);
    OpenFile.open(file.path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Excel exported to: $path")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Total Bill Report")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentBills.isEmpty
          ? const Center(child: Text("No bills found 😶"))
          : ListView.builder(
        itemCount: studentBills.length,
        itemBuilder: (context, index) {
          final roll = studentBills.keys.elementAt(index);
          final bill = studentBills[roll]!;
          return ListTile(
            title: Text(" Roll: $roll"),
            trailing: Text("₹${bill.toStringAsFixed(2)}"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: exportToExcel,
        icon: const Icon(Icons.download),
        label: const Text("Export Excel"),
      ),
    );
  }
}
