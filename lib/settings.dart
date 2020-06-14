import 'package:flutter/material.dart';
import 'package:storysoftware/theme/style.dart';

import 'PageNames.dart';
import 'custom_drawer.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Builder(
        builder: (ctx) => IconButton(
          icon:  new Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
        title: Text('Settings', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        backgroundColor: appTheme().primaryColor,
      ),
      drawer: CustomDrawer(PageNames.Settings),
    );
  }
}