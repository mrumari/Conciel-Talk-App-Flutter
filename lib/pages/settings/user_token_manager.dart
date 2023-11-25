import 'package:matrix/matrix.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void writeFcmTokenReference(User user, String fcmToken) {
  FirebaseFirestore.instance.collection('tokens').doc(user.id).set({
    'token': fcmToken,
  });
  readFcmTokenReference(user);
  Logs().i(
    '[TOKEN] -  sent $fcmToken',
  );
}

void readFcmTokenReference(User user) async {
  final DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('tokens').doc(user.id).get();
  Logs().i('[TOKEN] - received: $snapshot');
}
