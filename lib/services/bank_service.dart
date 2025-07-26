import 'package:cheque_manager/models/bank_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _bankCollection = FirebaseFirestore.instance
      .collection('Bank');

  // 🔹 Add a new bank
  Future<void> addBank(BankModel bank) async {
    try {
      final docRef = await _bankCollection.add(bank.toJson());
      print("Bank added with ID: ${docRef.id}");
    } catch (e) {
      print("Error adding bank: $e");
      rethrow;
    }
  }

  // 🔹 Fetch all banks
  Future<List<BankModel>> fetchBanks() async {
    try {
      final snapshot = await _bankCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return BankModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print("Error fetching banks: $e");
      return [];
    }
  }

  // 🔹 Update a bank by ID
  Future<void> updateBank(String id, BankModel updatedBank) async {
    try {
      await _bankCollection.doc(id).update(updatedBank.toJson());
      print("Bank updated");
    } catch (e) {
      print("Error updating bank: $e");
      rethrow;
    }
  }

  // 🔹 Delete a bank by ID
  Future<void> deleteBank(String id) async {
    try {
      await _bankCollection.doc(id).delete();
      print("Bank deleted");
    } catch (e) {
      print("Error deleting bank: $e");
      rethrow;
    }
  }
}
