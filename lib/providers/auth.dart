import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/http_exception.dart';
import 'dart:async';                                                    //helps in async methods as well as for setting up timers
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {                                 //try to use JWT(JSON Web TOkens instead in the authorization methodology
  String _token;
  DateTime _expiryDate;
  String _userID;
  Timer _authTimer;

  bool get isAuth {
    return getToken != null;
  }

  String get getToken {
    if(_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null){
      return _token;
    }
    return null;
  }

  String get getUserID {
    return _userID;
  }

  Future<void> _authenticate (String email,String password, String urlSegment) async {

    final url = "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCHeruI38qnk7sE4r7FhNZODyrXo2nZRD4";

    try {
      final response = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
      ),);
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userID = responseData['localId'];                                           //response returns a map of parameters which have to be referred by there key names
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));

      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token' : _token,
        'userID' : _userID,
        'expiryDate' : _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    }
    catch (error) {
      throw error;
    }
  }

  Future<void> signUp (String email, String password) async {

    return _authenticate(email, password, "signUp");                                            //returning the Future is important as we want to wait for the Future of authenticate as well.
    }

  Future<void> signIn (String email, String password) async {

    return _authenticate(email, password, "signInWithPassword");
  }


  Future<bool> tryAutoLogin() async {

    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('userData')){
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String,Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }

    _token = extractedUserData['token'];
    _userID = extractedUserData['userID'];
    _expiryDate = expiryDate;
    notifyListeners();

    _autoLogout();                                   //logging out when the expiryDate becomes more than the current time
    return true;
  }


  Future<void> logout() async {
    _token = null;
    _userID = null;
    _expiryDate = null;
    if(_authTimer != null)
    {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
//    prefs.remove('userData');
    prefs.clear();                                                                 //to clear out the SharedPrefs data when you logout
  }

  void _autoLogout() {
    if(_authTimer != null)
      {
        _authTimer.cancel();                                                      //to cancel the existing timers if there is one
      }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);                  //user will be logged out in the "seconds" argument duration
  }
}