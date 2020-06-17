import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:storysoftware/theme/style.dart';

import 'PageNames.dart';
import 'custom_drawer.dart';

class LibraryPage extends StatefulWidget {
@override
_LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _isPlaying = false;
  String url = "https://thepaciellogroup.github.io/AT-browser-tests/audio/jeffbob.mp3";

  AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Builder(
        builder: (ctx) => IconButton(
          icon:  new Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
        title: Text('Library', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        backgroundColor: appTheme().primaryColor,
      ),
      drawer: CustomDrawer(PageNames.Library),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  onPressed: () async {
                    setState(() {
                      _isPlaying = true;
                    });

                  },

                  child: Text(
                    'Load Audio File',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}