import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic> _userData = {};
  bool _userLoading = true;

  Map<String, dynamic> get userData => _userData;
  bool get userLoading => _userLoading;

  void setUserData(Map<String, dynamic> userData) {
    _userData = userData;
    notifyListeners();
  }

  void setUserLoading(bool userLoading) {
    _userLoading = userLoading;
    notifyListeners();
  }
}
