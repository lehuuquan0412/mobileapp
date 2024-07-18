import 'package:flutter/material.dart';
import 'vin_decoder.dart';

class ManualVinPage extends StatefulWidget {
  @override
  _ManualVinPageState createState() => _ManualVinPageState();
}

class _ManualVinPageState extends State<ManualVinPage> {
  final TextEditingController _vinController = TextEditingController();
  Map<String, String> _vinDetails = {};

  void _decodeVin() {
    String vin = _vinController.text;
    if (vin.length == 17) {
      setState(() {
        _vinDetails = VINDecoder().readVinAsMap(vin);
      });
    } else {
      setState(() {
        _vinDetails = {'Error': 'Please enter a valid 17-character VIN.'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manually Enter VIN',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _vinController,
                style: TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter VIN (17 characters)',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  counterStyle: TextStyle(color: Colors.white54),
                ),
                maxLength: 17,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _decodeVin,
                  child: Text('Decode VIN', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 243, 244, 245),
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildVinDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVinDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _vinDetails.keys.map((key) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                Colors.grey[900], // Consistent background with FirebaseVinPage
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '$key: ${_vinDetails[key]}',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      }).toList(),
    );
  }
}
