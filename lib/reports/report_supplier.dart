import 'package:cheque_manager/models/cheque_model.dart';
import 'package:cheque_manager/services/cheque_service.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SupplierReportPage extends StatefulWidget {
  const SupplierReportPage({super.key});

  @override
  State<SupplierReportPage> createState() => _SupplierReportPageState();
}

class _SupplierReportPageState extends State<SupplierReportPage> {
  final ChequeService _chequeService = ChequeService();
  List<ChequeModel> _cheques = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  String? _selectedSupplier;
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 30));
    _endDate = now;
    _loadCheques();
  }

  Future<void> _loadCheques() async {
    setState(() => _loading = true);
    final cheques = await _chequeService.fetchCheques();
    setState(() {
      _cheques = cheques;
      _loading = false;
    });
  }

  List<String> get _supplierSuggestions {
    final allSuppliers = _cheques.map((e) => e.supplierName).toSet().toList();
    allSuppliers.sort();
    return allSuppliers
        .where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<ChequeModel> get _filteredCheques {
    return _cheques.where((cheque) {
      final matchSupplier =
          _searchQuery.isEmpty ||
          cheque.supplierName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchDate =
          (_startDate == null ||
              cheque.date.isAfter(
                _startDate!.subtract(const Duration(days: 1)),
              )) &&
          (_endDate == null ||
              cheque.date.isBefore(_endDate!.add(const Duration(days: 1))));
      return matchSupplier && matchDate;
    }).toList();
  }

  double get _totalAmount =>
      _filteredCheques.fold(0.0, (sum, item) => sum + item.amount);

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _downloadAndShareReport() async {
    final pdf = pw.Document();
    final data = _filteredCheques;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Emerald Trade Centre Hettipola',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Supplier-wise Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              if (_startDate != null && _endDate != null)
                pw.Text(
                  'From: ${DateFormat.yMMMd().format(_startDate!)}  To: ${DateFormat.yMMMd().format(_endDate!)}',
                ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Supplier',
                  'Cheque No',
                  'GRN No',
                  'Amount',
                  'Status',
                ],
                data: data.map((cheque) {
                  return [
                    DateFormat.yMMMd().format(cheque.date),
                    cheque.supplierName,
                    cheque.chequeNumber.toString(),
                    cheque.grnNumber.toString(), // GRN Number here
                    'Rs. ${cheque.amount.toStringAsFixed(2)}',
                    cheque.status.toUpperCase(),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellPadding: const pw.EdgeInsets.all(5),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total Amount: Rs. ${_totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'supplier_cheque_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "Supplier Report",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 250,
        child: FloatingActionButton.extended(
          onPressed: _downloadAndShareReport,
          label: const Text(
            "Download Report as PDF",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.picture_as_pdf),
          backgroundColor: mainColor,
          foregroundColor: backgroundColor,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    // horizontal: 16,
                    // vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: backgroundColor,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              _startDate == null || _endDate == null
                                  ? "Select Date Range"
                                  : "From ${DateFormat.yMMMd().format(_startDate!)} to ${DateFormat.yMMMd().format(_endDate!)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search Supplier (by Name)',
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _selectedSupplier = null;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty && _selectedSupplier == null)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView(
                            shrinkWrap: true,
                            children: _supplierSuggestions.map((suggestion) {
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  suggestion,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  setState(() {
                                    _searchQuery = suggestion;
                                    _selectedSupplier = suggestion;
                                    _searchController.text = suggestion;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Total Amount: Rs. ${_totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade800,
                      ),
                      dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.shade900,
                      ),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      dataTextStyle: const TextStyle(color: Colors.white70),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Supplier")),
                        DataColumn(label: Text("Cheque No")),
                        DataColumn(
                          label: Text("GRN No"),
                        ), // Added GRN No column
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Status")),
                      ],
                      rows: _filteredCheques.map((cheque) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat.yMMMd().format(cheque.date)),
                            ),
                            DataCell(Text(cheque.supplierName)),
                            DataCell(Text(cheque.chequeNumber.toString())),
                            DataCell(
                              Text(cheque.grnNumber.toString()),
                            ), // Added GRN No
                            DataCell(
                              Text("Rs. ${cheque.amount.toStringAsFixed(2)}"),
                            ),
                            DataCell(Text(cheque.status.toUpperCase())),
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
