import 'package:cheque_manager/models/cheque_model.dart';
import 'package:cheque_manager/services/cheque_service.dart';
import 'package:cheque_manager/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChequeSearchPage extends StatefulWidget {
  const ChequeSearchPage({super.key});

  @override
  State<ChequeSearchPage> createState() => _ChequeSearchPageState();
}

class _ChequeSearchPageState extends State<ChequeSearchPage> {
  final ChequeService _chequeService = ChequeService();
  final TextEditingController _searchController = TextEditingController();
  List<ChequeModel> _allCheques = [];
  List<ChequeModel> _filteredCheques = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCheques();
  }

  Future<void> _loadCheques() async {
    final cheques = await _chequeService.fetchCheques();
    setState(() {
      _allCheques = cheques;
      _filteredCheques = cheques;
      _loading = false;
    });
  }

  void _filterCheques(String query) {
    final filtered = _allCheques
        .where(
          (cheque) => cheque.chequeNumber.toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    setState(() => _filteredCheques = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: mainColor,
        foregroundColor: backgroundColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Cheque Number',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white12,
                    ),
                    onChanged: _filterCheques,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredCheques.isEmpty
                        ? const Center(child: Text('No cheques found'))
                        : ListView.builder(
                            itemCount: _filteredCheques.length,
                            itemBuilder: (context, index) {
                              final cheque = _filteredCheques[index];
                              return Card(
                                color: Colors.grey[900],
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cheque #${cheque.chequeNumber}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: mainColor,
                                        ),
                                      ),
                                      Text(
                                        'GRN #${cheque.grnNumber}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          //color: mainColor,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      _buildDetailRow(
                                        'Date',
                                        DateFormat.yMMMd().format(cheque.date),
                                      ),
                                      _buildDetailRow(
                                        'Supplier',
                                        cheque.supplierName,
                                      ),
                                      _buildDetailRow('Bank', cheque.bankName),
                                      _buildDetailRow(
                                        'Amount',
                                        'Rs. ${cheque.amount.toStringAsFixed(2)}',
                                      ),
                                      _buildDetailRow(
                                        'Status',
                                        cheque.status.toUpperCase(),
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
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
