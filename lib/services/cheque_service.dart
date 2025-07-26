import 'package:cheque_manager/models/cheque_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChequeService {
  final CollectionReference _chequeCollection = FirebaseFirestore.instance
      .collection('Cheque');

  Future<void> addCheque(ChequeModel cheque) async {
    try {
      final docRef = _chequeCollection.doc();
      await docRef.set(cheque.toJson());
      print("✅ Cheque added with ID: ${docRef.id}");
    } catch (e) {
      print("❌ Error adding cheque: $e");
      rethrow;
    }
  }

  Future<List<ChequeModel>> fetchCheques() async {
    try {
      final snapshot = await _chequeCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChequeModel.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching cheques: $e");
      return [];
    }
  }

  Future<void> updateCheque(String id, ChequeModel updatedCheque) async {
    try {
      await _chequeCollection.doc(id).update(updatedCheque.toJson());
      print("✅ Cheque updated: $id");
    } catch (e) {
      print("❌ Error updating cheque: $e");
      rethrow;
    }
  }

  Future<void> deleteCheque(int chequeNumber) async {
    try {
      final snapshot = await _chequeCollection
          .where('chequeNumber', isEqualTo: chequeNumber)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        print("✅ Cheque deleted: $chequeNumber");
      }
    } catch (e) {
      print("❌ Error deleting cheque: $e");
      rethrow;
    }
  }

  Future<ChequeModel?> getChequeById(String id) async {
    try {
      final doc = await _chequeCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ChequeModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print("❌ Error fetching cheque by ID: $e");
      return null;
    }
  }

  Future<void> updateChequeStatus(int chequeNumber, String status) async {
    try {
      final snapshot = await _chequeCollection
          .where('chequeNumber', isEqualTo: chequeNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'status': status});
        print("✅ Status updated for cheque: $chequeNumber");
      }
    } catch (e) {
      print("❌ Error updating status: $e");
      rethrow;
    }
  }
}
