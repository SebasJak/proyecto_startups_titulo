import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/startup_project.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final apiProjectsProvider = FutureProvider<List<StartupProject>>((ref) async {
  final firestore = ref.watch(firestoreProvider);
  
  // Fetch from 'startups' collection
  final snapshot = await firestore.collection('startups').get();
  
  return snapshot.docs.map((doc) {
    final data = doc.data();
    return StartupProject(
      id: doc.id,
      name: data['name'] ?? 'Sin nombre',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      deckUrl: data['deckUrl'] ?? '',
      ownerPhoneNumber: data['ownerPhoneNumber'] ?? '',
      surveyUrl: data['surveyUrl'],
      likesCount: data['likesCount'] ?? 0,
      isLikedByMe: data['isLikedByMe'] ?? false,
    );
  }).toList();
});

// Method to submit a new startup to Firestore
Future<void> submitStartupToFirebase(Map<String, dynamic> startupData) async {
  await FirebaseFirestore.instance.collection('startups').add(startupData);
}

Future<void> incrementLikeCount(String docId) async {
  await FirebaseFirestore.instance.collection('startups').doc(docId).update({
    'likesCount': FieldValue.increment(1),
  });
}

Future<void> decrementLikeCount(String docId) async {
  await FirebaseFirestore.instance.collection('startups').doc(docId).update({
    'likesCount': FieldValue.increment(-1),
  });
}
