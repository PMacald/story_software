import 'package:flutter/material.dart';
import 'package:storysoftware/theme/style.dart';

import 'PageNames.dart';
import 'custom_drawer.dart';

class NowPlayingPage extends StatefulWidget {
  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Builder(
        builder: (ctx) => IconButton(
          icon:  new Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
        title: Text('Now Playing', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        backgroundColor: appTheme().primaryColor,
      ),
      drawer: CustomDrawer(PageNames.NowPlaying),
    );
  }
}