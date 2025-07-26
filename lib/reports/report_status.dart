import 'package:cheque_manager/models/cheque_model.dart';
import 'package:cheque_manager/services/cheque_service.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ChequeStatusReportPage extends StatefulWidget {
  const ChequeStatusReportPage({super.key});

  @override
  State<ChequeStatusReportPage> createState() => _ChequeStatusReportPageState();
}

class _ChequeStatusReportPageState extends State<ChequeStatusReportPage> {
  final ChequeService _chequeService = ChequeService();
  List<ChequeModel> _allCheques = [];
  String _selectedFilter = 'Last 7 Days';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCheques();
  }

  Future<void> _loadCheques() async {
    setState(() => _loading = true);
    final cheques = await _chequeService.fetchCheques();
    setState(() {
      _allCheques = cheques;
      _loading = false;
    });
  }

  DateTime get _filterStartDate {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Last 30 Days':
        return now.subtract(const Duration(days: 30));
      case 'Last 6 Months':
        return DateTime(now.year, now.month - 6, now.day);
      case 'Last 7 Days':
      default:
        return now.subtract(const Duration(days: 7));
    }
  }

  List<ChequeModel> get _filteredCheques {
    return _allCheques.where((c) => c.date.isAfter(_filterStartDate)).toList();
  }

  Map<String, int> get _statusCounts {
    final counts = {'passed': 0, 'returned': 0, 'pending': 0};
    for (var cheque in _filteredCheques) {
      if (counts.containsKey(cheque.status)) {
        counts[cheque.status] = counts[cheque.status]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _statusCounts;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Cheque Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        foregroundColor: backgroundColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter by Date Range:",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedFilter = val);
                          }
                        },
                        dropdownColor: backgroundColor,
                        items: ['Last 7 Days', 'Last 30 Days', 'Last 6 Months']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: chartData.entries.map((entry) {
                        final color = entry.key == 'passed'
                            ? Colors.green
                            : entry.key == 'returned'
                            ? Colors.red
                            : Colors.orange;
                        return PieChartSectionData(
                          color: color,
                          value: entry.value.toDouble(),
                          title: '${entry.key.toUpperCase()}\n${entry.value}',
                          radius: 70,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey.shade800,
                      ),
                      dataRowColor: MaterialStateProperty.all(
                        Colors.grey.shade900,
                      ),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      dataTextStyle: const TextStyle(color: Colors.white70),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Cheque No")),
                        DataColumn(label: Text("Supplier")),
                        DataColumn(
                          label: Text("GRN No"),
                        ), // Added GRN Number Column
                        DataColumn(label: Text("Status")),
                      ],
                      rows: _filteredCheques.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(Text(DateFormat.yMMMd().format(c.date))),
                            DataCell(Text(c.chequeNumber.toString())),
                            DataCell(Text(c.supplierName)),
                            DataCell(
                              Text(c.grnNumber.toString()),
                            ), // Added GRN Number in the row
                            DataCell(Text(c.status.toUpperCase())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
