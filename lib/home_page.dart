import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:storysoftware/theme/style.dart';
import 'dart:developer' as developer;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Location _userLocation;
  String _mapStyle;
  LocationData _currentLocation;
  Set<Marker> _onScreenMarkers = {};
  Map<String, Set<Marker>> _futureUpcomingMarkers = Map();
  int _distanceToNextObjective = 100000;
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  LatLng _nextObjectiveLatLng;
  bool _proximityThresholdReached = false;
  bool _playButtonVisible = false;
  bool _isPlaying = false;
  String url =
      "https://thepaciellogroup.github.io/AT-browser-tests/audio/jeffbob.mp3";
  AudioPlayer audioPlayer;
  bool _inCloseProximityToCurrentObjective = false;
  int _distanceThreshold = 330;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(48.8584, 2.2945),
    zoom: 18,
  );

  @override
  void initState() {
    super.initState();
    audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    rootBundle.loadString('assets/map_styles.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    _setUpMap();

    return new Scaffold(
      body: Stack(children: [
        (new GoogleMap(
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            controller.setMapStyle(_mapStyle);
            _controller.complete(controller);
          },
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          markers: _onScreenMarkers,
        )),
        Align(
          alignment: Alignment.bottomCenter,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              new Container(
                width: 100,
                height: 100,
                decoration: new BoxDecoration(
                  color: appTheme().primaryColorDark,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${_distanceToNextObjective.toString()}m",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: appTheme().primaryColorLight,
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _playButtonVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: RaisedButton(

                  onPressed: () {
                    if (_isPlaying == true) {
                      pauseAudio();
                      setState(() {
                        _isPlaying = false;
                      });
                    } else {
                      playAudioFromUrl(url);
                      // resumeAudio();
                      setState(() {
                        _isPlaying = true;
                      });
                    }
                  },
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  color: appTheme().primaryColorLight,
                ),
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToUser,
        child: Icon(Icons.person_pin_circle),
        backgroundColor: appTheme().primaryColor,
      ),
    );
  }

  void _setUpMap() {
    // set up user location for use
    _userLocation = new Location();

    _userLocation.onLocationChanged().listen((LocationData cLoc) {
      setState(() {
        _currentLocation = cLoc;
      });

      _updateUserPin();
    });

    _setUpFirestorePointsOnMap('spooky_tour');
  }

  void _setUpFirestorePointsOnMap(String collectionName) async {
    QuerySnapshot snapshot =
    await firestore.collection(collectionName).getDocuments();
    List<DocumentSnapshot> docs = snapshot.documents;

    for (DocumentSnapshot doc in docs) {
      GeoPoint geo = doc["location"];

      LatLng loc = new LatLng(geo.latitude, geo.longitude);

      String name = doc["name"];

      //todo: change after testing
      if (doc["groupIndex"] == "abc") {
        _setNextObjectiveLocation(loc);
        _addNextUpcomingMarker(
            doc.documentID, loc, BitmapDescriptor.hueRed, doc["groupIndex"]);
      } else {
        _addFutureMarker(
            doc.documentID, loc, BitmapDescriptor.hueMagenta, doc["groupIndex"]);
      }
    }
  }

  _addFutureMarker(String markerId, LatLng loc, double hue, String index) {
    setState(() {
      if (!_futureUpcomingMarkers.containsKey(index)) {
        _futureUpcomingMarkers[index] = Set<Marker>();
      }

      _futureUpcomingMarkers[index].add(Marker(
        markerId: MarkerId(markerId),
        position: loc,
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () async {
          // log location on tap
          Placemark x = (await Geolocator()
              .placemarkFromCoordinates(loc.latitude, loc.longitude))[0];
          developer
              .log("${x.name}, ${x.subLocality} , ${x.postalCode} tapped. ");
        },
      ));
    });
  }

  _updateSetOfMarkers(String index) {
    _onScreenMarkers = _futureUpcomingMarkers[index];
  }

  _setNextObjectiveLocation(LatLng latLng) {
    setState(() {
      _nextObjectiveLatLng = latLng;
    });
  }

  _updateDistance(LatLng landmark) async {
    int distance = (await Geolocator().distanceBetween(
        _currentLocation.longitude,
        _currentLocation.latitude,
        landmark.longitude,
        landmark.latitude))
        .round();
    setState(() {
      _distanceToNextObjective = distance;
    });

    if (_distanceToNextObjective <= _distanceThreshold && !_proximityThresholdReached) {
      _proximityThresholdReached = true;
      _inCloseProximityToCurrentObjective = true;

      Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      /*AlertDialog alert = AlertDialog(
        title: Text("Location Threshold crossed"),
        content: Text("You are less than 330m from the next objective."),
        actions: <Widget>[
          okButton,
        ],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });*/

      //todo: update to next set of markers dynamically
      _updateSetOfMarkers("xyz");
      playAudioFromUrl(this.url);
      _isPlaying = true;
      _playButtonVisible = !_playButtonVisible;
    }
    else if (_inCloseProximityToCurrentObjective == true && _distanceToNextObjective > _distanceThreshold) {
      _inCloseProximityToCurrentObjective = false;

      _updateTargetChoice();
    }
  }

  _updateTargetChoice() {
    //todo: update to next objective dynamically depending on direction of user

  }

  Future<DocumentReference> _addGeoPointToFirestore(Location location) async {
    var pos = await location.getLocation();
    GeoFirePoint point =
    geo.point(latitude: pos.latitude, longitude: pos.longitude);
    return firestore
        .collection('locations')
        .add({'position': point.data, 'name': 'Yay I can be queried!'});
  }

  Future<void> _goToUser() async {
    if (_userLocation != null) {
      final GoogleMapController controller = await _controller.future;

      LatLng userLatLng =
      new LatLng(_currentLocation.latitude, _currentLocation.longitude);
      controller.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 12));
    }
  }

  void _updateMarkerPins(String nextSetIndex) {
    setState(() {
      for (Marker marker in _futureUpcomingMarkers[nextSetIndex]) {
        _onScreenMarkers.add(marker);
      }
    });
  }

  void _updateUserPin() {
    setState(() {
      var pinPosition =
      LatLng(_currentLocation.latitude, _currentLocation.longitude);

      if (_onScreenMarkers.any((m) => m.markerId.value == "personPin")) {
        _onScreenMarkers.removeWhere((m) => m.markerId.value == "personPin");
      } else {
        // navigate to user if first version of pin is being placed
        _goToUser();
      }

      _addNextUpcomingMarker(
          "personPin", pinPosition, BitmapDescriptor.hueOrange, "me");
      _updateDistance(_nextObjectiveLatLng);
    });
  }

  // for use when determining a decided next point (ie. one fixed location)
  void _addNextUpcomingMarker(String markerId, LatLng loc, double hue,
      String index) {
    setState(() {
      if (_onScreenMarkers.any((element) => element.markerId.value == markerId))
        return;

      _onScreenMarkers.add(Marker(
        markerId: MarkerId(markerId),
        position: loc,
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () async {
          // log location on tap
          Placemark x = (await Geolocator()
              .placemarkFromCoordinates(loc.latitude, loc.longitude))[0];
          developer
              .log("${x.name}, ${x.subLocality} , ${x.postalCode} tapped. ");
        },
      ));
    });
  }

  playAudioFromUrl(url) async {
    int response = await audioPlayer.play(url, isLocal: false, volume: 1.0);

    if (response == 1) {
      // success

    } else {
      print('Some error occured in playing from url!');
    }
  }

  pauseAudio() async {
    int response = await audioPlayer.pause();

    if (response == 1) {
      // success

    } else {
      print('Some error occured in pausing');
    }
  }

  stopAudio() async {
    int response = await audioPlayer.stop();

    if (response == 1) {
      // success

    } else {
      print('Some error occurred in stopping');
    }
  }

  resumeAudio() async {
    int response = await audioPlayer.resume();

    if (response == 1) {
      // success

    } else {
      print('Some error occured in resuming');
    }
  }
}
