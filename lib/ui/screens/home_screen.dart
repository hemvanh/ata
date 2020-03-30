import 'package:ata/core/services/fingerprint_service.dart';
import 'package:ata/ui/widgets/qrcode_scanner_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ata/ui/screens/check_in_screen.dart';
import 'package:ata/ui/screens/user_settings_screen.dart';
import 'package:ata/ui/screens/login_screen.dart';
import 'package:ata/core/services/auth_service.dart';
import 'package:ata/ui/screens/report_screen.dart';
import 'package:ata/ui/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AuthService _authService;
  FingerPrintService _fingerPrintService;
  List<Map<String, Object>> _tabs;
  final List<Widget> _screens = [
    CheckInScreen(),
    ReportScreen(),
    UserSettingsScreen(),
    SettingsScreen(),
  ];
  int _selectedTabIndex = 0;
  PageController _pageController;
  @override
  void initState() {
    super.initState();
    _tabs = [
      {
        'title': Text('Check In/Out'),
        'icon': Icon(Icons.playlist_add_check),
      },
      {
        'title': Text('Reports'),
        'icon': Icon(Icons.chrome_reader_mode),
      },
      {
        'title': Text('Profile'),
        'icon': Icon(Icons.person),
      },
      {
        'title': Text('Admin'),
        'icon': Icon(Icons.settings),
      },
    ];
    _pageController = new PageController();
    WidgetsBinding.instance.addObserver(this);
    _authService = Provider.of<AuthService>(context, listen: false);
    _fingerPrintService = Provider.of<FingerPrintService>(context, listen: false);
  }

  Future<void> _signOutToLoginScreen() async {
    await _authService.signOut();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        if (!isDialogCreated) {
          final prefs = await SharedPreferences.getInstance();
          if (prefs.containsKey('loginData')) {
            bool isExpiredToken = await _authService.autoSignIn();
            if (!isExpiredToken) {
              (await _fingerPrintService.authenticate()).fold(
                (failure) async {
                  await showQrCodeSannerDialog();
                },
                (authenticated) async {
                  if (authenticated) {
                    String tokenError = await _authService.refeshToken();
                    if (tokenError != null) await _signOutToLoginScreen();
                  } else
                    await showQrCodeSannerDialog();
                },
              );
            }
          }
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  //Animates the controlled [PageView] from the current page to the given page.
  void _navigateToPage(int index) {
    _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
  }

  void _changeTab(int index) {
    setState(() {
      this._selectedTabIndex = index;
    });
  }

  bool isDialogCreated = false;
  Future showQrCodeSannerDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        isDialogCreated = true;
        return QrcodeScannerDialog();
      },
    ).then((_) {
      isDialogCreated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Attendance Tracking'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await _signOutToLoginScreen();
              },
            ),
          ],
        ),
        body: PageView(
          children: _screens,
          controller: _pageController,
          onPageChanged: _changeTab,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedTabIndex,
          onTap: _navigateToPage,
          items: _tabs
              .map((tab) => BottomNavigationBarItem(
                    icon: tab['icon'],
                    title: tab['title'],
                  ))
              .toList(),
        ),
      ),
    );
  }
}
