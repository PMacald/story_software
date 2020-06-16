import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  Set<Marker> _markers = {};
  int _distanceToNextObjective = 100000;
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  LatLng _nextObjectiveLatLng;
  bool _proximityThresholdReached = false;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(48.8584, 2.2945),
    zoom: 18,
  );

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_styles.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  Widget build(BuildContext context) {

    _setUpMap();

    return new Scaffold(
      body: Stack(
        children: [(
        new GoogleMap(
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(_mapStyle);
          _controller.complete(controller);
        },
          mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        markers: _markers,
      )),
          Center(
            child: Align(
              alignment: Alignment.bottomCenter,
              child:
              Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                ),
                  child: Align(
                    child: Text(
                      "${_distanceToNextObjective.toString()}m",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                ),
              )
            )
          )
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
    QuerySnapshot snapshot = await firestore.collection(collectionName).getDocuments();
    List<DocumentSnapshot> docs = snapshot.documents;

    for (DocumentSnapshot doc in docs) {
      GeoPoint geo = doc["location"];

      LatLng loc = new LatLng(geo.latitude, geo.longitude);

      String name = doc["name"];

      if (doc["index"] == 1) {
        _setNextObjectiveLocation(loc);
      }

      _addMarker(doc.documentID, loc, BitmapDescriptor.hueMagenta, doc["index"]);
    }
  }

  _setNextObjectiveLocation(LatLng latLng) {
    setState(() {
      _nextObjectiveLatLng = latLng;
    });
  }

   _updateDistance(LatLng landmark) async {
    int distance = (await Geolocator().distanceBetween(_currentLocation.longitude, _currentLocation.latitude, landmark.longitude, landmark.latitude)).round();
    setState(() {
      _distanceToNextObjective = distance;
    });

    if (_distanceToNextObjective <= 330 && !_proximityThresholdReached) {
      _proximityThresholdReached = true;

      Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () {Navigator.pop(context);},
      );

      AlertDialog alert = AlertDialog(
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
        }
      );
    }
  }

  Future<DocumentReference> _addGeoPointToFirestore(Location location) async {
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    return firestore.collection('locations').add({
      'position': point.data,
      'name': 'Yay I can be queried!'
    });
  }

  Future<void> _goToUser() async {
    if (_userLocation != null) {
      final GoogleMapController controller = await _controller.future;

      LatLng userLatLng = new LatLng(_currentLocation.latitude, _currentLocation.longitude);
      controller.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 12));
    }
  }

 void _updateUserPin()  {
      setState(() {
        var pinPosition = LatLng(
            _currentLocation.latitude, _currentLocation.longitude);

        //todo: tidy up expression
        if (_markers.any((m) => m.markerId.value == "personPin")) {
          _markers.removeWhere((m) => m.markerId.value == "personPin");
        }
        else {
          // navigate to user if first version of pin is being placed
          _goToUser();
        }

        _addMarker("personPin", pinPosition, BitmapDescriptor.hueOrange, 0);
        _updateDistance(_nextObjectiveLatLng);
      });
  }

  void _addMarker(String markerId, LatLng loc, double hue, index) {
    setState(() {
      if (_markers.any((element) => element.markerId.value == markerId))
        return;

      _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: loc,
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () async {
          // log location on tap
          Placemark x = (await Geolocator().placemarkFromCoordinates(loc.latitude, loc.longitude))[0];
          developer.log("${x.name}, ${x.subLocality} , ${x.postalCode} tapped. ");
        },
      ));
    });
  }
}