import 'package:cloud_firestore/cloud_firestore.dart';

class ChequeModel {
  final int chequeNumber;
  final int grnNumber;
  final String supplierName;
  final String bankName;
  final int amount;
  final DateTime date;
  final String status; // NEW FIELD: passed, returned, or pending

  ChequeModel({
    required this.chequeNumber,
    required this.grnNumber,
    required this.supplierName,
    required this.bankName,
    required this.amount,
    required this.date,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'chequeNumber': chequeNumber,
      'grnNumber': grnNumber,
      'supplierName': supplierName,
      'bankName': bankName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }

  factory ChequeModel.fromJson(Map<String, dynamic> map) {
    return ChequeModel(
      chequeNumber: map['chequeNumber'] is int
          ? map['chequeNumber']
          : int.tryParse(map['chequeNumber'].toString()) ?? 0,
      grnNumber: map['grnNumber'] is int
          ? map['grnNumber']
          : int.tryParse(map['grnNumber'].toString()) ?? 0,
      supplierName: map['supplierName'] ?? '',
      bankName: map['bankName'] ?? '',
      amount: map['amount'] is int
          ? map['amount']
          : int.tryParse(map['amount'].toString()) ?? 0,
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date'].toString()) ?? DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }
}
