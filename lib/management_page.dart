import 'package:cheque_manager/bank_new_add.dart';
import 'package:cheque_manager/reports/report_history.dart';
import 'package:cheque_manager/reports/report_status.dart';
import 'package:cheque_manager/reports/report_supplier.dart';
import 'package:cheque_manager/supplier_new_add.dart';
import 'package:cheque_manager/reports/report_search.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:flutter/material.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItemData(
        title: "Supplier Report",
        icon: Icons.bar_chart,
        page: const SupplierReportPage(),
      ),
      _MenuItemData(
        title: "History Report",
        icon: Icons.bar_chart,
        page: const ChequeReportPage(),
      ),
      _MenuItemData(
        title: "Search Cheque",
        icon: Icons.search,
        page: const ChequeSearchPage(),
      ),
      _MenuItemData(
        title: "Cheque Status",
        icon: Icons.checklist,
        page: const ChequeStatusReportPage(),
      ),
      _MenuItemData(
        title: "Add New Supplier",
        icon: Icons.business,
        page: const AddSupplierPage(),
      ),
      _MenuItemData(
        title: "Add New Bank",
        icon: Icons.account_balance,
        page: const AddBankPage(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        foregroundColor: backgroundColor,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: menuItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.page),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 28, color: mainColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItemData {
  final String title;
  final IconData icon;
  final Widget page;

  _MenuItemData({required this.title, required this.icon, required this.page});
}
