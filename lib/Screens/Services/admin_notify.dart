import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getAllTokens() async {
    final snapshot = await _firestore.collection('tokens').get();
    return snapshot.docs.map((doc) => doc['token'] as String).toList();
  }
}
