import 'package:cheque_manager/models/cheque_model.dart';
import 'package:cheque_manager/services/cheque_service.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ChequeReportPage extends StatefulWidget {
  const ChequeReportPage({super.key});

  @override
  State<ChequeReportPage> createState() => _ChequeReportPageState();
}

class _ChequeReportPageState extends State<ChequeReportPage> {
  final ChequeService _chequeService = ChequeService();
  List<ChequeModel> _cheques = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;

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

  List<ChequeModel> get _filteredCheques {
    return _cheques.where((cheque) {
      if (_startDate != null && cheque.date.isBefore(_startDate!)) return false;
      if (_endDate != null && cheque.date.isAfter(_endDate!)) return false;
      return true;
    }).toList();
  }

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
                'Cheque History Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                _startDate != null && _endDate != null
                    ? 'From: ${DateFormat.yMMMd().format(_startDate!)}  To: ${DateFormat.yMMMd().format(_endDate!)}'
                    : 'All Cheques',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Supplier', 'Cheque No', 'GRN No', 'Amount'],
                data: data.map((cheque) {
                  return [
                    DateFormat.yMMMd().format(cheque.date),
                    cheque.supplierName,
                    cheque.chequeNumber.toString(),
                    cheque.grnNumber.toString(), // Added GRN Number here
                    'Rs. ${cheque.amount.toStringAsFixed(2)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellPadding: const pw.EdgeInsets.all(5),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'cheque_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "History Report",
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                const SizedBox(height: 15),
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
                          ],
                        );
                      }).toList(),
                    ),
                  ),
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
    );
  }
}
