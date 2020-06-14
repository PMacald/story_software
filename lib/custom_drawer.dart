import 'package:flutter/material.dart';
import 'package:storysoftware/PageNames.dart';
import 'package:storysoftware/home_page.dart';
import 'package:storysoftware/library_page.dart';
import 'package:storysoftware/report_an_issue_page.dart';
import 'package:storysoftware/settings.dart';
import 'package:storysoftware/theme/style.dart';

import 'now_playing_page.dart';

class CustomDrawer extends StatelessWidget {
  PageNames _currentTab;

  CustomDrawer(PageNames currentTabName) {
    _currentTab = currentTabName;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(icon: Icons.map, text: 'Map',),
          _createDrawerItem(icon: Icons.library_books, text: 'Library',
            onTap: () {
              _navigateToNewPage(PageNames.Library, context);
          },),
          _createDrawerItem(
            icon: Icons.play_circle_outline, text: 'Now Playing',
            onTap: () {
              _navigateToNewPage(PageNames.NowPlaying, context);
            },),
          //Divider(),
          _createDrawerItem(icon: Icons.settings, text: 'Settings',
            onTap: () {
              _navigateToNewPage(PageNames.Settings, context);
            },),
          Divider(),
          _createDrawerItem(icon: Icons.bug_report, text: 'Report an issue',
            onTap: () {
              _navigateToNewPage(PageNames.ReportAnIssue, context);
            },),
        ],
      ),
    );
  }

  void _navigateToNewPage(PageNames destination, BuildContext context) {
    StatefulWidget destinationPage;

    switch (destination) {
      case PageNames.Map:
        destinationPage = HomePage();
        break;
      case PageNames.Library:
        destinationPage = LibraryPage();
        break;
      case PageNames.NowPlaying:
        destinationPage = NowPlayingPage();
        break;
      case PageNames.Settings:
        destinationPage = SettingsPage();
        break;
      case PageNames.ReportAnIssue:
        destinationPage = ReportAnIssuePage();
        break;
    }

    Navigator.pop(context);

    if (_currentTab != PageNames.Map) {
      Navigator.pop(context);
    }

    if (_currentTab != destination) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destinationPage),
      );
    }
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            color: appTheme().primaryColor,
            ),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Storytelling Prototype",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}