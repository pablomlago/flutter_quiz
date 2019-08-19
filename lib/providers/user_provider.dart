import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final String _token;
  final String _userId;
  String name;
  int experience;
  List<User> leaderBoard = [];

  UserProvider(
    this._token,
    this._userId,
  );

  Future<void> fetchUserData() async {
    final String url =
        'https://[FIREBASE_URL].firebaseio.com/users/$_userId.json';
    final http.Response response = await http.get(url);
    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }
    name = responseData['name'];
    experience = responseData['experience'];
  }

  Future<void> fetchLeaderBoard() async {
    final String url =
        'https://[FIREBASE_URL].firebaseio.com/users.json?orderBy="experience"&limitToLast=100';
    final http.Response response = await http.get(url);
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }
    final List<User> loadedUsers = [];
    responseData.forEach((String id, userData) {
      loadedUsers.add(
        User(
          userData['name'],
          userData['experience'],
        ),
      );
    });
    loadedUsers.sort((a, b) => b.experience - a.experience);
    leaderBoard = loadedUsers;
    notifyListeners();
  }

  Future<void> addExperience(int extraExperience) async {
    final String url =
        'https://[FIREBASE_URL].firebaseio.com/users/$_userId.json';
    final http.Response response = await http.patch(
      url,
      body: json.encode(
        {
          'experience': experience + extraExperience,
        },
      ),
    );
    final responseData = json.decode(response.body);

    if (responseData['error'] != null) {
      throw HttpException(responseData['error']['message']);
    }
    experience += extraExperience;
    notifyListeners();
  }
}
