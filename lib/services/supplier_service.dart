import 'package:cheque_manager/models/supplier_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _supplierCollection = FirebaseFirestore.instance
      .collection('Supplier');

  // 🔹 Add a new supplier (auto-ID)
  Future<void> addSupplier(SupplierModel supplier) async {
    try {
      final docRef = await _supplierCollection.add(supplier.toJson());
      print("Supplier added with ID: ${docRef.id}");
    } catch (e) {
      print("Error adding supplier: $e");
      rethrow;
    }
  }

  // 🔹 Fetch all suppliers
  Future<List<SupplierModel>> fetchSuppliers() async {
    try {
      final snapshot = await _supplierCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SupplierModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print("Error fetching suppliers: $e");
      return [];
    }
  }

  // 🔹 Update supplier by ID
  Future<void> updateSupplier(String id, SupplierModel updatedSupplier) async {
    try {
      await _supplierCollection.doc(id).update(updatedSupplier.toJson());
      print("Supplier updated");
    } catch (e) {
      print("Error updating supplier: $e");
      rethrow;
    }
  }

  // 🔹 Delete supplier by ID
  Future<void> deleteSupplier(String id) async {
    try {
      await _supplierCollection.doc(id).delete();
      print("Supplier deleted");
    } catch (e) {
      print("Error deleting supplier: $e");
      rethrow;
    }
  }

  // 🔍 Search supplier names (for dropdown search)
  Future<List<String>> searchSuppliersByName(String query) async {
    try {
      final snapshot = await _supplierCollection
          .where('supplierName', isGreaterThanOrEqualTo: query)
          .where('supplierName', isLessThan: query + 'z')
          .get();

      return snapshot.docs
          .map((doc) => doc['supplierName'].toString())
          .toList();
    } catch (e) {
      print("Error searching suppliers: $e");
      return [];
    }
  }
}
