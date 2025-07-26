class BankModel {
  final String id;
  final String bankName;
  final int accountNumber;

  BankModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
  });

  Map<String, dynamic> toJson() {
    return {'bankName': bankName, 'accountNumber': accountNumber};
  }

  factory BankModel.fromJson(Map<String, dynamic> map) {
    return BankModel(
      id: map['id'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] is int
          ? map['accountNumber']
          : int.tryParse(map['accountNumber'].toString()) ?? 0,
    );
  }
}
