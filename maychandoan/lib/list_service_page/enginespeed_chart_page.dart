import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'pressure_chart_page.dart';
import 'package:maychandoan/second_page.dart';
import 'package:flutter/services.dart';

class EngineSpeedChartPage extends StatefulWidget {
  const EngineSpeedChartPage({super.key});

  @override
  State<EngineSpeedChartPage> createState() => _EngineSpeedChartPageState();
}

class _EngineSpeedChartPageState extends State<EngineSpeedChartPage> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  final databaseRef =
      FirebaseDatabase.instance.ref('ReadLiveData/engine_speed');
  List<FlSpot> speedPoints = [];
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
    subscribeToEngineSpeed();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) updateData();
    });
  }

  void subscribeToEngineSpeed() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as int?;
      if (data != null && mounted) {
        addDataPoint(data.toDouble());
      }
    }, onError: (error) {
      // Handle errors or log them
      print('Error subscribing to engine speed: $error');
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

  void addDataPoint(double newSpeed) {
    setState(() {
      xValue += step;
      speedPoints.add(FlSpot(xValue, newSpeed));
      speedPoints.removeWhere((point) => point.x < xValue - 13);
    });
  }

  void updateData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! < 0) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PressureChartPage()));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: speedPoints.isNotEmpty
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
                child: Text('Engine Speed (RPM)',
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
              child: Text('Engine Speed Chart',
                  style: TextStyle(
                      color: Color.fromARGB(255, 190, 123, 224),
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
                    size: 30, color: Color.fromARGB(255, 238, 237, 237)),
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
      maxY: 6000,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color.fromARGB(
                255, 112, 112, 112), // Change to your desired color
            strokeWidth: 1.0,
            dashArray: [5, 3], // Set the thickness of the line
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color.fromARGB(
                255, 112, 112, 112), // Change to your desired color
            strokeWidth: 1.0,
            dashArray: [5, 3], // Set the thickness of the line
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: const Color.fromARGB(255, 243, 242, 242), width: 4),
          left: BorderSide(
              color: const Color.fromARGB(255, 242, 241, 241), width: 4),
          right: BorderSide(color: Color.fromARGB(0, 245, 244, 244)),
          top: BorderSide(color: Color.fromARGB(0, 237, 236, 236)),
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
            spots: speedPoints,
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
      case 1000:
        text = Text('1000',
            style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Times'));
        break;
      case 3000:
        text = Text('3000',
            style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Times'));
        break;
      case 5000:
        text = Text('5000',
            style: TextStyle(
                color: Colors.green,
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
