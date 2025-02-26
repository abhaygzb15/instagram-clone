import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'package:flutter/widgets.dart';
import 'package:instagram_clone/models/user.dart';

class UserProvider with ChangeNotifier{
  User? _user;
  final AuthMethods _authMethods=AuthMethods();

// User get getUser => _user!;
  User? get getUser => _user; // Return user or null

  Future<void> refreshUser() async {
    User user=await _authMethods.getUserDetails();
    _user=user;
    notifyListeners();
  }
}