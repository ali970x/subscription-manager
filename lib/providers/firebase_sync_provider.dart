import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/firebase_sync_service.dart';

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>(
  (ref) => FirebaseSyncService(),
);

final firebaseUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseSyncServiceProvider).authChanges,
);
