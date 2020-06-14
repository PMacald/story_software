import 'package:flutter/material.dart';
import 'package:storysoftware/theme/style.dart';

import 'PageNames.dart';
import 'custom_drawer.dart';

class ReportAnIssuePage extends StatefulWidget {
  @override
  _ReportAnIssuePageState createState() => _ReportAnIssuePageState();
}

class _ReportAnIssuePageState extends State<ReportAnIssuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Builder(
        builder: (ctx) => IconButton(
          icon:  new Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
        title: Text('Report an Issue', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        backgroundColor: appTheme().primaryColor,
      ),
      drawer: CustomDrawer(PageNames.ReportAnIssue),
    );
  }
}