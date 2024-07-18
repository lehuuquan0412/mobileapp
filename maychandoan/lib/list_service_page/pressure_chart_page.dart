import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'enginespeed_chart_page.dart';
import 'package:maychandoan/second_page.dart';
import 'package:flutter/services.dart';

class PressureChartPage extends StatefulWidget {
  const PressureChartPage({super.key});

  @override
  State<PressureChartPage> createState() => _PressureChartPageState();
}

class AppColors {
  static const Color contentColorCyan = Color(0xFF00BCD4);
  static const Color contentColorBlue = Color(0xFF2196F3);
}

class _PressureChartPageState extends State<PressureChartPage> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  final databaseRef = FirebaseDatabase.instance.ref('ReadLiveData/intake_map');
  List<FlSpot> pressurePoints = [];
  double xValue = 0;
  double step = 1; // Equivalent to 2 seconds per step

  late Timer timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    subscribeToMAP();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) updateData();
    });
  }

  void subscribeToMAP() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as int?;
      if (data != null && mounted) {
        addDataPoint(data.toDouble());
      }
    }, onError: (error) {
      // Handle errors or log them
      print('Error subscribing to MAP: $error');
    });
  }

  @override
  void dispose() {
    timer.cancel();
    databaseRef.onDisconnect();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void addDataPoint(double newPressure) {
    setState(() {
      // Increment xValue each time a new data point is added
      xValue += step;

      // Add the new data point
      pressurePoints.add(FlSpot(xValue, newPressure));

      // Remove points that are outside the visible range of 14 seconds
      pressurePoints.removeWhere((point) => point.x < xValue - 13);
    });
  }

  void updateData() {
    // Triggered every 2 seconds by the timer
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EngineSpeedChartPage()));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: pressurePoints.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.only(
                          top: 40, bottom: 20, left: 20, right: 60),
                      height: screenHeight * 0.9,
                      child: LineChart(mainChartData()))
                  : CircularProgressIndicator(),
            ),
            Positioned(
              top: screenHeight * 0.45, // Adjusted dynamically
              left: screenWidth * -0.05, // Adjusted dynamically
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: Text('Mass Air Pressure (kPA)',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Times',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.05, // Adjusted dynamically
              right: screenWidth * 0.4, // Adjusted dynamically
              child: Text('Times (sec)',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Times',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold)),
            ),
            Positioned(
              bottom: screenHeight * 0.88, // Adjusted dynamically
              right: screenWidth * 0.35, // Adjusted dynamically
              child: Text('Mass Air Pressure Chart',
                  style: TextStyle(
                      color: Color.fromARGB(255, 113, 157, 239),
                      fontSize: 20,
                      fontFamily: 'Times',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold)),
            ),
            Positioned(
              top: screenHeight * 0.05, // Adjusted dynamically
              left: screenWidth * 0.05, // Adjusted dynamically
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    size: 30, color: Color.fromARGB(255, 251, 250, 250)),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SecondPage()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainChartData() {
    return LineChartData(
      minX: xValue > 13 ? xValue - 13 : 0,
      maxX: xValue > 13 ? xValue : 13,
      minY: 0,
      maxY: 300,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.white, width: 4),
          left: BorderSide(color: Colors.white, width: 4),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 100,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
            spots: pressurePoints,
            isCurved: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueGrey.withOpacity(0.7), // Set your desired color
            ),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ))
      ],
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    Widget text;
    switch (value.toInt()) {
      case 50:
        text = const Text('50',
            style: TextStyle(
                color: Color.fromARGB(255, 174, 45, 45),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Times'));
        break;
      case 100:
        text = const Text('100',
            style: TextStyle(
                color: Color.fromARGB(255, 224, 195, 49),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Times'));

        break;
      case 150:
        text = const Text('150',
            style: TextStyle(
                color: Color.fromARGB(255, 133, 210, 82),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Times'));
        break;
      case 200:
        text = const Text('200',
            style: TextStyle(
                color: Color.fromARGB(255, 88, 223, 223),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Times'));
        break;
      case 250:
        text = const Text('250',
            style: TextStyle(
                color: Color.fromARGB(255, 205, 72, 60),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Times'));
        break;

      default:
        text = const Text('');
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 15, // Default value
      child: text,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    int displayValue = (value + (xValue > 13 ? xValue - 13 : 0)).toInt();
    if (displayValue % 2 == 0) {
      return Text('$displayValue',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Times',
              fontWeight: FontWeight.bold,
              fontSize: 15));
    }
    return const Text('');
  }
}
