import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:storysoftware/theme/style.dart';

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
    // create an instance of Location
    _userLocation = new Location();

    _userLocation.onLocationChanged().listen((LocationData cLoc) {
      setState(() {
        _currentLocation = cLoc;
      });

      _updateUserPin();
    });

    return new Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(_mapStyle);
          _controller.complete(controller);
        },
        zoomControlsEnabled: false,
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToUser,
        label: Text('My Location'),
        icon: Icon(Icons.person_pin_circle),
        backgroundColor: appTheme().primaryColor,
      ),
    );
  }

  Future<void> _goToUser() async {
    if (_userLocation != null) {
      final GoogleMapController controller = await _controller.future;

      LatLng userLatLng = new LatLng(_currentLocation.latitude, _currentLocation.longitude);
      controller.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 18));
    }
  }

  void _updateUserPin() {
    setState(() {
      var pinPosition = LatLng(_currentLocation.latitude, _currentLocation.longitude);

      //todo: tidy up expression
      if (_markers.any((m) => m.markerId.value == "personPin")) {
        _markers.removeWhere((m) => m.markerId.value == "personPin");
      }
      else {
        // navigate to user if first pin is being placed
        _goToUser();
      }

      _markers.add(Marker(
        markerId: MarkerId("personPin"),
        position: pinPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });
  }
}