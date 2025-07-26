class SupplierModel {
  final String id;
  final String supplierName;
  final int creditPeriod;
  final String mobileNumber;

  SupplierModel({
    required this.id,
    required this.supplierName,
    required this.creditPeriod,
    required this.mobileNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'supplierName': supplierName,
      'creditPeriod': creditPeriod,
      'mobileNumber': mobileNumber,
    };
  }

  factory SupplierModel.fromJson(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] ?? '',
      supplierName: map['supplierName'] ?? '',
      creditPeriod: map['creditPeriod'] is int
          ? map['creditPeriod']
          : int.tryParse(map['creditPeriod'].toString()) ?? 0,
      mobileNumber: map['mobileNumber'] ?? '',
    );
  }
}
