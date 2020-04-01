import 'package:ata/core/services/auth_service.dart';
import 'package:ata/core/services/fingerprint_service.dart';
import 'package:ata/ui/screens/home_screen.dart';
import 'package:ata/ui/screens/login_screen.dart';
import 'package:ata/ui/widgets/qr_code_scanner_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReAuthRedirect extends StatefulWidget {
  static const routeName = '/reauth-redirect';
  @override
  _ReAuthRedirectState createState() => _ReAuthRedirectState();
}

class _ReAuthRedirectState extends State<ReAuthRedirect> {
  AuthService _authService;
  FingerPrintService _fingerPrintService;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _fingerPrintService = Provider.of<FingerPrintService>(context, listen: false);
  }

  bool isDialogShown = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: reauth(),
      builder: (ctx, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Container();
        else
          return snapshot.data ? HomeScreen() : LoginScreen();
      },
    );
  }

  Future<void> _signOutToLoginScreen() async {
    await _authService.signOut();
    navTo(LoginScreen.routeName);
  }

  Future<bool> showQrCodeSannerDialog() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        //* Prevent Dialog dismissed on Back button pressed
        return WillPopScope(
          onWillPop: () async => false,
          child: QrCodeScannerDialog(),
        );
      },
    );
  }

  Future<void> navTo(String routeName) async {
    await Future<void>.microtask(() {
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }

  Future<bool> isLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('loginData')) {
      prefs.clear();
      return false;
    } else
      return true;
  }

  Future<bool> reauth() async {
    //* Check if logged in before
    bool isLoggedInBefore = await _authService.checkSharedPref();
    if (!isLoggedInBefore) return false;

    //* If Logged in before, then the token is still valid ?
    bool isValidToken = await _authService.validateToken();
    if (isValidToken)
      return true;
    else {
      bool isReAuth = false;

      //* Fingerscan authentication
      (await _fingerPrintService.authenticate()).fold(
        (failure) async {
          isReAuth = false;
        },
        (authenticated) async {
          isReAuth = authenticated;
        },
      );

      //* QR Code authentication
      if (!isReAuth) {
        isReAuth = await showQrCodeSannerDialog();
      }

      //* Refresh Token if re-authenticated
      if (isReAuth) {
        String tokenError = await _authService.refeshToken();
        if (tokenError != null) await _signOutToLoginScreen();
      }
      isDialogShown = true;
      return isReAuth;
    }
  }
}
