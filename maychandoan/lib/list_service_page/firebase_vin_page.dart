import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vin_decoder.dart';

class FirebaseVinPage extends StatefulWidget {
  @override
  _FirebaseVinPageState createState() => _FirebaseVinPageState();
}

class _FirebaseVinPageState extends State<FirebaseVinPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  String _vin = '';
  Map<String, String> _decodedResult = {};

  @override
  void initState() {
    super.initState();
    _fetchVinFromFirebase();
  }

  void _fetchVinFromFirebase() async {
    DataSnapshot snapshot = await _databaseReference.child('vehicle/VIN').get();
    String vin = snapshot.value as String? ?? '';
    if (vin.isNotEmpty && vin.length == 17) {
      setState(() {
        _vin = vin;
        _decodedResult = VINDecoder().readVinAsMap(vin);
      });
    } else {
      setState(() {
        _decodedResult = {
          'Error': 'The VIN from Firebase is invalid or not found.'
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          'Your Vehicle VIN',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Times',
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 2.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('VIN from Firebase: $_vin',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 170, 168, 168))),
            SizedBox(height: 20),
            if (_decodedResult.containsKey('Country'))
              _buildDetailBox('Country', _decodedResult['Country']!),
            if (_decodedResult.containsKey('Year'))
              _buildDetailBox('Year', _decodedResult['Year']!),
            if (_decodedResult.containsKey('Manufacturer'))
              _buildDetailBox('Manufacturer', _decodedResult['Manufacturer']!),
            if (_decodedResult.containsKey('Error'))
              _buildDetailBox('Error', _decodedResult['Error']!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title: $value',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Arial',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
