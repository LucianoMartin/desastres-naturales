import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alerta.dart';

class AlertaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Alerta>> obtenerAlertas() {
    return _firestore.collection('alertas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Alerta.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }
}
