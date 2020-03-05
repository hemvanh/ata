import 'package:flutter/foundation.dart';

class User {
  String email;
  String displayName;
  String photoUrl;
  String error;

  User({@required this.email, @required this.displayName, @required this.photoUrl, @required this.error});

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      email: parsedJson['email'],
      displayName: parsedJson['displayName'],
      photoUrl: parsedJson['photoUrl'],
      error: parsedJson['error'] == null ? null : parsedJson['error'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'email': this.email,
      'displayName': this.displayName,
      'photoUrl': this.photoUrl,
    };
  }
}
