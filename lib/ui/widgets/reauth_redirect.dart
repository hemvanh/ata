import 'package:ata/core/services/auth_service.dart';
import 'package:ata/core/services/fingerprint_service.dart';
import 'package:ata/ui/screens/home_screen.dart';
import 'package:ata/ui/screens/login_screen.dart';
import 'package:ata/ui/widgets/auth_redirect.dart';
import 'package:ata/ui/widgets/qrcode_scanner_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReauthRedirect extends StatefulWidget {
  static const routeName = '/reauth-redirect';
  @override
  _ReauthRedirectState createState() => _ReauthRedirectState();
}

class _ReauthRedirectState extends State<ReauthRedirect> {
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

  Future showQrCodeSannerDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        //* Prevent Dialog dismissed on Back button pressed
        return WillPopScope(
          onWillPop: () async => false,
          child: QrcodeScannerDialog(),
        );
      },
    );
  }

  Future<void> navTo(String routeName) async {
    await Future<void>.microtask(() {
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }

  Future<bool> reauth() async {
    if (!isDialogShown) {
      bool isAuth = false;

      // Fingerscan authentication
      (await _fingerPrintService.authenticate()).fold(
        (failure) async {
          isAuth = false;
        },
        (authenticated) async {
          isAuth = authenticated;
        },
      );

      //QR Code authentication
      if (!isAuth) {
        await showQrCodeSannerDialog();
      }

      // Refresh Token if re-authenticated
      if (isAuth) {
        String tokenError = await _authService.refeshToken();
        if (tokenError != null) await _signOutToLoginScreen();
      }
      isDialogShown = true;
      return isAuth;
    } else {
      navTo(AuthRedirect.routeName);
      return false;
    }
  }
}
