import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IsLoginProvider extends ChangeNotifier{
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool value){
    _isLoggedIn = value;
    notifyListeners();
  }
}