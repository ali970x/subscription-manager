import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/subscription_model.dart';

class FirebaseSyncService {
  FirebaseSyncService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : auth = auth ?? FirebaseAuth.instance,
      firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  bool _googleInitialized = false;

  User? get currentUser => auth.currentUser;
  Stream<User?> get authChanges => auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<UserCredential> createAccount(String email, String password) => auth
      .createUserWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return auth.signInWithPopup(GoogleAuthProvider());
    }
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }
    final googleUser = await GoogleSignIn.instance.authenticate();
    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );
    return auth.signInWithCredential(credential);
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) =>
      firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _subscriptions(String uid) =>
      _userDocument(uid).collection('subscriptions');

  Future<void> backup(List<SubscriptionModel> items) async {
    final user = currentUser;
    if (user == null) throw StateError('Sign in before backing up data.');

    final existing = await _subscriptions(user.uid).get();
    final localIds = items.map((item) => item.id).toSet();
    final writes = <Future<void>>[];

    writes.add(
      _userDocument(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'schemaVersion': 1,
        'lastBackupAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );

    for (final document in existing.docs) {
      if (!localIds.contains(document.id)) {
        writes.add(document.reference.delete());
      }
    }
    for (final item in items) {
      writes.add(
        _subscriptions(user.uid).doc(item.id).set({
          ...item.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      );
    }
    await Future.wait(writes);
  }

  Future<List<SubscriptionModel>> restore() async {
    final user = currentUser;
    if (user == null) throw StateError('Sign in before restoring data.');
    final snapshot = await _subscriptions(user.uid).get();
    final items = snapshot.docs.map((document) {
      final data = Map<String, dynamic>.from(document.data())
        ..remove('updatedAt');
      return SubscriptionModel.fromJson(data);
    }).toList();
    items.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    return items;
  }

  Future<List<SubscriptionModel>> syncOnLogin(
    List<SubscriptionModel> localItems,
  ) async {
    final remoteItems = await restore();
    if (remoteItems.isEmpty) {
      await backup(localItems);
      return localItems;
    }
    return remoteItems;
  }

  Future<void> signOutWithBackup(List<SubscriptionModel> items) async {
    if (currentUser != null) await backup(items);
    await auth.signOut();
    if (_googleInitialized) await GoogleSignIn.instance.signOut();
  }
}
