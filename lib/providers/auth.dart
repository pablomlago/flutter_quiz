import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;


  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=[API_KEY]';
    try {
      final http.Response response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]';
    try {
      final http.Response response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      final String urlDatabase =
          'https://[FIREBASE_URL].firebaseio.com/users/${responseData['localId']}.json';
      final http.Response responseDatabase = await http.put(
        urlDatabase,
        body: jsonEncode({
          'name': name,
          'experience': 0,
        }),
      );
      final responseDatabaseData = json.decode(responseDatabase.body);
      if (responseDatabaseData['error'] != null) {
        final String urlDelete =
            'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=[API_KEY]';
        final http.Response responseDelete = await http.post(
          url,
          body: json.encode(
            {
              'idToken': responseData['idToken'],
            },
          ),
        );
        final responseDeleteData = json.decode(responseDelete.body);
        if(responseDeleteData['error']['message'] != null) {
          throw HttpException(responseDeleteData['error']['message']);
        }
        throw HttpException(responseDatabaseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  void addUser(String userName) {
    const String url = 'https://[FIREBASE_URL].firebaseio.com/users/123.json';
    http
        .get(
      url,
    )
        .then((http.Response response) {
      print(response.body.startsWith('null'));
    });
  }

  /*
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }*/

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final Map<String, dynamic> extractedUserData = json.decode(
      prefs.getString('userData'),
    );
    final DateTime expiryData = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryData.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryData;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final int timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
