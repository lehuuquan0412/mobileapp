import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maychandoan/login_page.dart';

import 'list_service_page/data_display_page.dart';
import 'list_service_page/search_dtc_page.dart';
import 'list_service_page/chat_page.dart';
import 'list_service_page/readvin_page.dart';
import 'list_service_page/read_dtc_page.dart';
import 'list_service_page/read_pending_dtc_page.dart';
import 'list_service_page/control_actuators_page.dart';
import 'list_service_page/enginespeed_chart_page.dart';
import 'package:maychandoan/first_page.dart';
import 'package:maychandoan/login_page.dart';
import 'list_service_page/gps_page.dart';

class SecondPage extends StatelessWidget {
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
              MaterialPageRoute(builder: (context) => FirstPage()),
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
          _buildButton(context, "Show Current Data",
              'assets/icons/data_display.png', DataDisplayPage()),
          _buildButton(context, "Show Stored DTC",
              'assets/icons/stored_dtc.png', ReadDTCPage()),
          _buildButton(context, "Show Pending DTC",
              'assets/icons/pending_dtc.png', ReadPendingDTCPage()),
          _buildButton(context, "Read & Decode VIN", 'assets/icons/vinid.png',
              ReadVinPage()),
          _buildButton(context, "Search DTC Information",
              'assets/icons/search_dtc.png', SearchDTCPage()),
          _buildButton(context, "Control Actuators",
              'assets/icons/control_actuators.png', ControlActuatorsPage()),
          _buildButton(
              context, "GPS Tracker", 'assets/icons/gps.png', GpsScreen()),
          _buildButton(context, "Draw Live Data Chart",
              'assets/icons/live_data_chart.png', EngineSpeedChartPage()),
          _buildButton(context, "Chat With Help Bot",
              'assets/icons/chat_bot.png', ChatPage()),
          _buildButton(
              context, "Log Out", 'assets/icons/logout.png', LoginPage()),
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
