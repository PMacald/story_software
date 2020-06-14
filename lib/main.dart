import 'package:flutter/material.dart';
import 'package:storysoftware/PageNames.dart';
import './home_page.dart';
import 'custom_drawer.dart';
import 'library_page.dart';
import 'theme/style.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  BuildContext _context;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(leading: Builder(
            builder: (ctx) => IconButton(
              icon:  new Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
            title: Text('Storytelling Prototype', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
            backgroundColor: appTheme().primaryColor,
          ),
          body: HomePage(),
          drawer: CustomDrawer(PageNames.Map),
        );
  }
}

