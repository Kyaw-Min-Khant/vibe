import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic> _userData = {};
  bool _userLoading = true;
  List<Map<String, dynamic>> _friRequestList = [];
  Map<String, dynamic> get userData => _userData;
  bool get userLoading => _userLoading;
  List<Map<String, dynamic>> get friRequestList => _friRequestList;

  void setUserData(Map<String, dynamic> userData) {
    _userData = userData;
    notifyListeners();
  }

  void setFriRequestList(List<Map<String, dynamic>> friRequestList) {
    _friRequestList = friRequestList;
    notifyListeners();
  }

  void removeFirRequest(String id) {
    print(id);
    _friRequestList = friRequestList
        .where((item) => item["_id"] != id)
        .toList();
  }

  void setUserLoading(bool userLoading) {
    _userLoading = userLoading;
    notifyListeners();
  }
}
