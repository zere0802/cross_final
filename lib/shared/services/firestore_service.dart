import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addSharedExpense({
    required String title,
    required double amount,
    required String category,
  }) async {

    print('ADDING TO FIREBASE');

    await _firestore
        .collection('sharedExpenses')
        .add({
      'title': title,
      'amount': amount,
      'category': category,
      'createdAt': Timestamp.now(),
    });

    print('SUCCESSFULLY ADDED');
  }

  Stream<QuerySnapshot> getSharedExpenses() {
    return _firestore
        .collection('sharedExpenses')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  Future<void> deleteExpense(
    String id,
  ) async {
    await _firestore
        .collection('sharedExpenses')
        .doc(id)
        .delete();
  }
}