import 'package:flutter/material.dart';
import 'manual_vin_page.dart'; // Ensure this file exists and is correctly set up
import 'firebase_vin_page.dart';
import 'package:maychandoan/second_page.dart'; // Ensure this file exists and is correctly set up

class ReadVinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar with black background
        title: Text(
          'List Of Services',
          style: TextStyle(
            fontFamily: 'Times',
            fontSize: 25,
            fontWeight: FontWeight.normal,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Color.fromARGB(255, 208, 206, 206),
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 247, 245, 245),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SecondPage()),
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color.fromARGB(225, 16, 15, 15), // Color of the divider line
            height: 2.0, // Thickness of the divider line
          ),
        ),
      ),
      backgroundColor: Colors.black, // Scaffold with black background
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: <Widget>[
          _buildButton(context, "Search VIN Infor",
              'assets/icons/searchVIN.png', ManualVinPage()),
          _buildButton(context, "Your Vehicle VIN",
              'assets/icons/vehicleVIN.png', FirebaseVinPage()),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, String iconPath, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
              color: Color.fromARGB(255, 143, 142, 142),
              width: 3), // White border around the button
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        backgroundColor: Color.fromARGB(255, 0, 0, 0), // Background color black
        foregroundColor: Color.fromARGB(255, 246, 244, 244), // Text color white
        elevation: 0, // Optional: adds shadow to the button
        shadowColor: Colors.black.withOpacity(1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 183, 183, 183).withOpacity(0),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            child: Image.asset(iconPath,
                width: 60,
                height: 60), // Image adjusted to not use ColorFiltered
          ),
          SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 9.0,
                  color: Colors.grey,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
