import 'package:cheque_manager/models/cheque_model.dart';
import 'package:cheque_manager/services/cheque_service.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChequeViewPage extends StatefulWidget {
  const ChequeViewPage({super.key});

  @override
  State<ChequeViewPage> createState() => _ChequeViewPageState();
}

class _ChequeViewPageState extends State<ChequeViewPage> {
  final ChequeService _chequeService = ChequeService();
  late DateTime _selectedDate;
  late Future<List<ChequeModel>> _chequesFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _chequesFuture = _loadChequesForDate(_selectedDate);
  }

  Future<List<ChequeModel>> _loadChequesForDate(DateTime date) async {
    final allCheques = await _chequeService.fetchCheques();
    return allCheques.where((cheque) => _isSameDate(cheque.date, date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _updateStatus(int chequeNumber, String status) async {
    await _chequeService.updateChequeStatus(chequeNumber, status);
    setState(() {
      _chequesFuture = _loadChequesForDate(_selectedDate);
    });
  }

  Future<void> _deleteCheque(int chequeNumber) async {
    await _chequeService.deleteCheque(chequeNumber);
    setState(() {
      _chequesFuture = _loadChequesForDate(_selectedDate);
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _chequesFuture = _loadChequesForDate(picked);
      });
    }
  }

  double _calculateTotalAmount(List<ChequeModel> cheques) {
    return cheques.fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "ChequeFlow",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        foregroundColor: backgroundColor,

        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: FutureBuilder<List<ChequeModel>>(
        future: _chequesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final cheques = snapshot.data ?? [];
          final totalAmount = _calculateTotalAmount(cheques);

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: backgroundColor,
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "Selected Date: $formattedDate",
                            style: const TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Total Amount: Rs. ${totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (cheques.isEmpty)
                    const Expanded(
                      child: Center(child: Text("No cheques found.")),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 85,
                          left: 16,
                          right: 16,
                          top: 5,
                        ),
                        itemCount: cheques.length,
                        itemBuilder: (context, index) {
                          final cheque = cheques[index];
                          final formatted = DateFormat.yMMMMd().format(
                            cheque.date,
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),

                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(11.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cheque #${cheque.chequeNumber} - ${cheque.supplierName}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Amount: Rs. ${cheque.amount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: mainColor.withOpacity(0.9),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.white,
                                        tooltip: "Delete Cheque",
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "Confirm Deletion",
                                              ),
                                              content: const Text(
                                                "Are you sure you want to delete this cheque?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteCheque(
                                                      cheque.chequeNumber,
                                                    );
                                                  },
                                                  child: const Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "GRN #${cheque.grnNumber}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Bank: ${cheque.bankName}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),

                                  // Text(
                                  //   "Date: $formatted",
                                  //   style: const TextStyle(
                                  //     fontSize: 14,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Status: ${cheque.status.toUpperCase()}",
                                        style: TextStyle(
                                          color: cheque.status == 'passed'
                                              ? Colors.green
                                              : cheque.status == 'returned'
                                              ? Colors.red
                                              : Colors.orange,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _updateStatus(
                                              cheque.chequeNumber,
                                              'passed',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 0,
                                              ),
                                            ),
                                            child: const Text(
                                              "PASSED",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () => _updateStatus(
                                              cheque.chequeNumber,
                                              'returned',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 0,
                                              ),
                                            ),
                                            child: const Text(
                                              "RETURNED",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              // Total Amount Floating Box
              // Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: 90,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       vertical: 10,
              //       horizontal: 20,
              //     ),
              //     decoration: BoxDecoration(
              //       color: mainColor,
              //       borderRadius: BorderRadius.circular(0),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black26,
              //           blurRadius: 10,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: Center(
              //       child: Text(
              //         "Total Amount: Rs. ${totalAmount.toStringAsFixed(2)}",
              //         style: TextStyle(
              //           fontSize: 16,
              //           //  fontWeight: FontWeight.bold,
              //           color: backgroundColor,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
