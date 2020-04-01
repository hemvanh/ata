import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ata/util.dart';
import 'package:ata/factories.dart';
import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/auth.dart';

enum AuthType { SignUp, SignIn }
final String dbUrl = 'https://atapp-7720c.firebaseio.com';

class AuthService {
  //* Model reference
  Either<Failure, Auth> _auth;
  Either<Failure, Auth> get auth => _auth;
  void _setAuth(Either<Failure, Auth> auth) {
    _auth = auth;
  }

  String get apiKey {
    return Auth.apiKey;
  }

  String get idToken {
    if (_auth == null) return null;
    return _auth.fold(
      (failuse) => null,
      (auth) => auth.idToken,
    );
  }

  bool get isAuth {
    if (_auth == null) return false;
    return _auth.fold(
      (failure) => false,
      (auth) => auth.idToken != null,
    );
  }

  String get getError {
    return _auth.fold(
      (failure) => null,
      (auth) => auth.error,
    );
  }

  String _getUrl(AuthType authType) {
    String firebaseAuthType;
    switch (authType) {
      case AuthType.SignUp:
        firebaseAuthType = 'signUp';
        break;
      case AuthType.SignIn:
        firebaseAuthType = 'signInWithPassword';
        break;
    }
    return 'https://identitytoolkit.googleapis.com/v1/accounts:$firebaseAuthType?key=$apiKey';
  }

  Future<String> authenticate(String email, String password, AuthType authType) async {
    _setAuth(
      await Util.requestEither<Auth>(
        RequestType.POST,
        _getUrl(authType),
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    if (getError != null) return getError;

    _auth.fold(
      (failure) => failure,
      (auth) async {
        // Saving to shared prefs
        final prefs = await SharedPreferences.getInstance();
        final loginJsonString = json.encode(auth.toJson());
        prefs.setString('loginData', loginJsonString);
      },
    );
    return null;
  }

  Future<void> signOut() async {
    _setAuth(null);
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<bool> checkSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('loginData')) {
      prefs.clear();
      return false;
    } else
      return true;
  }

  Future<bool> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final loginData = json.decode(prefs.getString('loginData')) as Map<String, Object>;
    if (loginData['expiringDate'] == null) {
      prefs.clear();
      return false;
    }
    final expiringDate = DateTime.parse(loginData['expiringDate']);

    if (expiringDate.isBefore(DateTime.now())) {
      return false;
    }

    _setAuth(await Task(
      () async => make<Auth>(loginData),
    ).attempt().mapLeftToFailure().run());

    return true;
  }

  Future<String> refeshToken() async {
    String urlRefeshToken = "https://securetoken.googleapis.com/v1/token?key=$apiKey";
    final prefs = await SharedPreferences.getInstance();
    final loginData = json.decode(prefs.getString('loginData')) as Map<String, Object>;
    try {
      var tokenData = await Util.request(RequestType.POST, urlRefeshToken, {
        'grant_type': "refresh_token",
        'refresh_token': loginData['refreshToken'],
      });
      if (tokenData['error'] != null) return tokenData['error'];

      loginData['expiringDate'] =
          DateTime.now().add(Duration(seconds: int.parse(tokenData['expires_in']))).toIso8601String();
      loginData['idToken'] = tokenData['id_token'];
      final loginJsonString = json.encode(loginData);
      prefs.setString('loginData', loginJsonString);

      _setAuth(await Task(
        () async => make<Auth>(loginData),
      ).attempt().mapLeftToFailure().run());
      return null;
    } catch (error) {
      return error.toString();
    }
  }
}
