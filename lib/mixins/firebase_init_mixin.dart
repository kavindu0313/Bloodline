import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

mixin FirebaseInitMixin<T extends StatefulWidget> on State<T> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      print('Initializing Firebase...');
      await FirebaseService.initializeFirebase();
      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  bool get isFirebaseInitialized => _isInitialized;
} 