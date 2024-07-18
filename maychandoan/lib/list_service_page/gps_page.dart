import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';

class GpsScreen extends StatefulWidget {
  @override
  _GpsScreenState createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  MapController mapController = MapController();
  LatLng _center = LatLng(0.0, 0.0); // Default center of the map

  @override
  void initState() {
    super.initState();
    _database.child('gps').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final latitude = double.tryParse(data['latitude'].toString());
        final longitude = double.tryParse(data['longitude'].toString());
        if (latitude != null && longitude != null) {
          setState(() {
            _center = LatLng(latitude, longitude);
            mapController.move(_center,
                mapController.zoom); // Ensuring we update the map's center
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(
          color: const Color.fromARGB(255, 215, 213, 212),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'GPS Tracker',
          style: TextStyle(
            color: const Color.fromARGB(255, 237, 230, 229),
            fontFamily: 'Times',
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: _center,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            // Using TileLayer instead of TileLayerWidget
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(
            // Using MarkerLayer instead of MarkerLayerWidget
            markers: [
              Marker(
                  point: _center, // Using the updated center from Firebase
                  width: 80.0,
                  height: 80.0,
                  child: const Icon(
                    Icons.my_location,
                    color: Color.fromARGB(255, 10, 10, 10),
                    size: 22,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
