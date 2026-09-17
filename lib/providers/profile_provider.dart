import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();

  Profile? _profile;
  bool _isLoading = false;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _service.getProfile(userId);
    } catch (e) {
      print('PROFILE LOAD ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String fullName,
    String? studentId,
    String? department,
    int? yearOfStudy,
  }) async {
    if (_profile == null) return;

    final updated = Profile(
      id: _profile!.id,
      fullName: fullName,
      studentId: studentId,
      department: department,
      yearOfStudy: yearOfStudy,
    );

    await _service.updateProfile(updated);
    _profile = updated;
    notifyListeners();
  }
}
