import 'package:flutter/foundation.dart';

class ProviderHelper with ChangeNotifier {
  var isLoggedIn = false;
  String userName = "";
  String avatarURL = "";
  String profilePicID = "";
  String bgImage = "assets/images/background3.jpg";

  logIn(String user, String avatar, String id) {
    isLoggedIn = true;
    userName = user;
    avatarURL = avatar;
    profilePicID = id;
    print(avatarURL);
    notifyListeners();
  }

  updateAvatarURL(String newURL) {
    avatarURL = newURL;
    notifyListeners();
  }

  logOut() {
    isLoggedIn = false;
    userName = "";
    notifyListeners();
  }
}
