import 'package:ata/screens/report_screen.dart';
import 'package:ata/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ata/providers/auth.dart';
import 'package:ata/screens/check_in_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, Object>> _tabs;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabs = [
      {
        'tab': CheckInScreen(),
        'title': Text('Check In/Out'),
        'icon': Icon(Icons.playlist_add_check),
      },
      {
        'tab': ReportScreen(),
        'title': Text('Reports'),
        'icon': Icon(Icons.chrome_reader_mode),
      },
      {
        'tab': SettingsScreen(),
        'title': Text('Settings'),
        'icon': Icon(Icons.settings),
      },
    ];
  }

  void _changeTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var selectedTab = _tabs[_selectedTabIndex];
    return Center(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Attendance Tracking'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => Provider.of<Auth>(context, listen: false).signOut(),
            ),
          ],
        ),
        body: selectedTab['tab'],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: _changeTab,
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
