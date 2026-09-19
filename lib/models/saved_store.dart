import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class SavedStore {
  SavedStore._();

  static const String databaseUrl =
      'https://bayan-travel-app-2026-default-rtdb.europe-west1.firebasedatabase.app';

  static final ValueNotifier<List<Map<String, dynamic>>> _savedDestinations =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  static StreamSubscription<DatabaseEvent>? _subscription;

  static String? _activeUid;

  static ValueNotifier<List<Map<String, dynamic>>> get savedDestinations {
    _ensureListening();
    return _savedDestinations;
  }

  static DatabaseReference? _savedReference() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );

    return database.ref(
      'users/${user.uid}/saved',
    );
  }

  static void _ensureListening() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _subscription?.cancel();
      _subscription = null;
      _activeUid = null;
      _savedDestinations.value = [];
      return;
    }

    if (_activeUid == user.uid && _subscription != null) {
      return;
    }

    _subscription?.cancel();

    _activeUid = user.uid;

    final DatabaseReference? reference = _savedReference();

    if (reference == null) {
      return;
    }

    _subscription = reference.onValue.listen(
      (DatabaseEvent event) {
        final Object? value = event.snapshot.value;

        final List<Map<String, dynamic>> loadedSavedPlaces = [];

        if (value is Map) {
          final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(value);

          data.forEach((key, value) {
            if (value is Map) {
              final Map<dynamic, dynamic> item =
                  Map<dynamic, dynamic>.from(value);

              loadedSavedPlaces.add({
                '_firebaseKey': key.toString(),
                'name': item['name']?.toString() ?? '',
                'location': item['location']?.toString() ?? '',
                'rating': item['rating']?.toString() ?? '0.0',
                'price': item['price']?.toString() ?? '',
                'image': item['image']?.toString() ?? '',
                'category': item['category']?.toString() ?? '',
                'createdAt': item['createdAt'] is num
                    ? (item['createdAt'] as num).toInt()
                    : 0,
              });
            }
          });
        }

        loadedSavedPlaces.sort(
          (a, b) => (b['createdAt'] as int).compareTo(
            a['createdAt'] as int,
          ),
        );

        _savedDestinations.value = loadedSavedPlaces;
      },
      onError: (Object error) {
        debugPrint(
          'Saved places Firebase error: $error',
        );
      },
    );
  }

  static bool isSaved(String destinationName) {
    _ensureListening();

    return _savedDestinations.value.any(
      (destination) => destination['name'] == destinationName,
    );
  }

  static Future<void> toggleDestination(
    Map<String, dynamic> destination,
  ) async {
    _ensureListening();

    final DatabaseReference? reference = _savedReference();

    if (reference == null) {
      return;
    }

    final String destinationName = destination['name']?.toString() ?? '';

    if (destinationName.isEmpty) {
      return;
    }

    final int existingIndex = _savedDestinations.value.indexWhere(
      (item) => item['name'] == destinationName,
    );

    if (existingIndex >= 0) {
      final Map<String, dynamic> existing =
          _savedDestinations.value[existingIndex];

      final String? firebaseKey = existing['_firebaseKey']?.toString();

      final List<Map<String, dynamic>> updatedList =
          List<Map<String, dynamic>>.from(
        _savedDestinations.value,
      );

      updatedList.removeAt(existingIndex);

      _savedDestinations.value = updatedList;

      if (firebaseKey != null && firebaseKey.isNotEmpty) {
        await reference.child(firebaseKey).remove();
      }

      return;
    }

    final DatabaseReference newSavedPlace = reference.push();

    final int now = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> savedData = {
      'name': destinationName,
      'location': destination['location']?.toString() ?? '',
      'rating': destination['rating']?.toString() ?? '0.0',
      'price': destination['price']?.toString() ?? '',
      'image': destination['image']?.toString() ?? '',
      'category': destination['category']?.toString() ?? '',
      'createdAt': now,
    };

    final Map<String, dynamic> localData = {
      ...savedData,
      '_firebaseKey': newSavedPlace.key,
    };

    _savedDestinations.value = [
      localData,
      ..._savedDestinations.value,
    ];

    try {
      await newSavedPlace.set(savedData);
    } catch (error) {
      _savedDestinations.value = _savedDestinations.value
          .where(
            (item) => item['_firebaseKey'] != newSavedPlace.key,
          )
          .toList();

      debugPrint(
        'Could not save destination: $error',
      );
    }
  }

  static Future<void> removeDestination(
    String destinationName,
  ) async {
    _ensureListening();

    final DatabaseReference? reference = _savedReference();

    if (reference == null) {
      return;
    }

    final int index = _savedDestinations.value.indexWhere(
      (item) => item['name'] == destinationName,
    );

    if (index < 0) {
      return;
    }

    final Map<String, dynamic> destination = _savedDestinations.value[index];

    final String? firebaseKey = destination['_firebaseKey']?.toString();

    final List<Map<String, dynamic>> updated = List<Map<String, dynamic>>.from(
      _savedDestinations.value,
    );

    updated.removeAt(index);

    _savedDestinations.value = updated;

    if (firebaseKey != null && firebaseKey.isNotEmpty) {
      await reference.child(firebaseKey).remove();
    }
  }

  static Future<void> clearAll() async {
    _ensureListening();

    final DatabaseReference? reference = _savedReference();

    if (reference == null) {
      return;
    }

    _savedDestinations.value = [];

    await reference.remove();
  }
}
