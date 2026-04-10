import 'package:flutter/foundation.dart';
import 'package:food_app/models/user_model.dart';
import 'package:food_app/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService userService;

  UserModel? _user;

  UserModel? get user => _user;

  UserProvider({required this.userService});

  void listenUser(String uid) {
    userService.getUser(uid).listen((user) {
      _user = user;
      notifyListeners();
    });
  }
}
