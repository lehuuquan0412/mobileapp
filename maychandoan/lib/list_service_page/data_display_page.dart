import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:maychandoan/second_page.dart';
import 'package:intl/intl.dart';

class DataDisplayPage extends StatefulWidget {
  @override
  _DataDisplayPageState createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage>
    with TickerProviderStateMixin {
  final databaseRef = FirebaseDatabase.instance.ref();

  String _enginespeedData = "0";
  String _vehiclespeedData = "0";
  String _LoadData = "0";
  String _CoolantTempData = "0";
  String _IntakeTempData = "0";
  String _IntakeMapData = "0";
  String _FlowData = "0";
  String _VoltageData = "0";
  String _timeString = '00:00:00';

  late StreamSubscription<DatabaseEvent>? _enginespeedSubscription;
  late StreamSubscription<DatabaseEvent>? _vehiclespeedSubscription;
  late StreamSubscription<DatabaseEvent>? _LoadSubscription;
  late StreamSubscription<DatabaseEvent>? _CoolantTempSubscription;
  late StreamSubscription<DatabaseEvent>? _IntakeTempSubscription;
  late StreamSubscription<DatabaseEvent>? _IntakeMapSubscription;
  late StreamSubscription<DatabaseEvent>? _FlowSubscription;
  late StreamSubscription<DatabaseEvent>? _VoltageSubcription;
  late Timer _timer;

  late AnimationController _radialAnimationControllerEngineSpeed;
  late AnimationController _radialAnimationControllerVehicleSpeed;
  late AnimationController _radialAnimationControllerLoad;
  late AnimationController _radialAnimationControllerIntakeMap;
  late AnimationController _radialAnimationControllerCoolantTemp;
  late AnimationController _radialAnimationControllerIntakeTemp;

  late Animation<double> _vehicleSpeedAnimation;
  late Animation<double> _engineSpeedAnimation;
  late Animation<double> _LoadAnimation;
  late Animation<double> _IntakeMapAnimation;
  late Animation<double> _CoolantTempAnimation;
  late Animation<double> _IntakeTempAnimation;

  void _getTime() {
    final String formattedDateTime =
        DateFormat('HH:mm:ss').format(DateTime.now()).toString();
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _getTime();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _resetFirebaseData();

    super.initState();
    _subscribeToEngineSpeedChanges();

    // Initialize animation controllers
    _radialAnimationControllerEngineSpeed = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _radialAnimationControllerVehicleSpeed = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _radialAnimationControllerLoad = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _radialAnimationControllerIntakeMap = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _radialAnimationControllerCoolantTemp = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _radialAnimationControllerIntakeTemp = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _vehicleSpeedAnimation =
        Tween<double>(begin: 0, end: double.parse(_vehiclespeedData)).animate(
            CurvedAnimation(
                parent: _radialAnimationControllerVehicleSpeed,
                curve: Curves.easeInOutBack))
          ..addListener(() {
            setState(() {});
          });
    _engineSpeedAnimation =
        Tween<double>(begin: 0, end: double.parse(_enginespeedData)).animate(
            CurvedAnimation(
                parent: _radialAnimationControllerEngineSpeed,
                curve: Curves.easeInOutBack))
          ..addListener(() {
            setState(() {});
          });
    _LoadAnimation = Tween<double>(begin: 0, end: double.parse(_LoadData))
        .animate(CurvedAnimation(
            parent: _radialAnimationControllerLoad,
            curve: Curves.easeInOutBack))
      ..addListener(() {
        setState(() {});
      });
    _IntakeMapAnimation =
        Tween<double>(begin: 0, end: double.parse(_IntakeMapData)).animate(
            CurvedAnimation(
                parent: _radialAnimationControllerIntakeMap,
                curve: Curves.easeInOutBack))
          ..addListener(() {
            setState(() {});
          });
    _CoolantTempAnimation =
        Tween<double>(begin: 0, end: double.parse(_CoolantTempData)).animate(
            CurvedAnimation(
                parent: _radialAnimationControllerCoolantTemp,
                curve: Curves.easeInOutBack))
          ..addListener(() {
            setState(() {});
          });
    _IntakeTempAnimation =
        Tween<double>(begin: 0, end: double.parse(_IntakeTempData)).animate(
            CurvedAnimation(
                parent: _radialAnimationControllerIntakeTemp,
                curve: Curves.easeInOutBack))
          ..addListener(() {
            setState(() {});
          });
  }

  void _resetFirebaseData() {
    // Define the paths and initial data
    Map<String, int> initialData = {
      'engine_speed': 0,
      'vehicle_speed': 0,
      'engine_load': 0,
      'coolant_temp': 0,
      'intake_temp': 0,
      'intake_map': 0,
      'flow': 0,
      'voltage': 0,
    };

    // Update Firebase with initial data
    initialData.forEach((key, value) {
      databaseRef.child('ReadLiveData/$key').set(value);
    });
  }

  void _subscribeToEngineSpeedChanges() {
    _enginespeedSubscription =
        databaseRef.child('ReadLiveData/engine_speed').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _enginespeedData) {
        setState(() {
          _enginespeedData = newData;
          // Update the Tween to start at the current animation value and end at the new data value
          double currentValue = _engineSpeedAnimation.value;
          _engineSpeedAnimation =
              Tween<double>(begin: currentValue, end: double.parse(newData))
                  .animate(CurvedAnimation(
                      parent: _radialAnimationControllerEngineSpeed,
                      curve: Curves.easeInOutBack));
          _radialAnimationControllerEngineSpeed.forward(
              from: 0); // Starts animation from current value to new value
        });
      }
    });
    _vehiclespeedSubscription =
        databaseRef.child('ReadLiveData/vehicle_speed').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _vehiclespeedData) {
        setState(() {
          _vehiclespeedData = newData;
          // Update the Tween to start at the current animation value and end at the new data value
          double currentValue = _vehicleSpeedAnimation.value;
          _vehicleSpeedAnimation =
              Tween<double>(begin: currentValue, end: double.parse(newData))
                  .animate(CurvedAnimation(
                      parent: _radialAnimationControllerLoad,
                      curve: Curves.easeInOutBack));
          _radialAnimationControllerLoad.forward(
              from: 0); // Starts animation from current value to new value
        });
      }
    });
    _LoadSubscription =
        databaseRef.child('ReadLiveData/engine_load').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _LoadData) {
        setState(() {
          _LoadData = newData;
          // Update the Tween to start at the current animation value and end at the new data value
          double currentValue = _LoadAnimation.value;
          _LoadAnimation =
              Tween<double>(begin: currentValue, end: double.parse(newData))
                  .animate(CurvedAnimation(
                      parent: _radialAnimationControllerVehicleSpeed,
                      curve: Curves.easeInOutBack));
          _radialAnimationControllerVehicleSpeed.forward(
              from: 0); // Starts animation from current value to new value
        });
      }
    });
    _IntakeMapSubscription =
        databaseRef.child('ReadLiveData/intake_map').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _IntakeMapData) {
        setState(() {
          _IntakeMapData = newData;
          // Update the Tween to start at the current animation value and end at the new data value
          double currentValue = _IntakeMapAnimation.value;
          _IntakeMapAnimation =
              Tween<double>(begin: currentValue, end: double.parse(newData))
                  .animate(CurvedAnimation(
                      parent: _radialAnimationControllerIntakeMap,
                      curve: Curves.easeInOutBack));
          _radialAnimationControllerIntakeMap.forward(
              from: 0); // Starts animation from current value to new value
        });
      }
    });
    _CoolantTempSubscription =
        databaseRef.child('ReadLiveData/coolant_temp').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _CoolantTempData) {
        setState(() {
          _CoolantTempData = newData;
          // Update the Tween to start at the current animation value and end at the new data value
          double currentValue = _CoolantTempAnimation.value;
          _CoolantTempAnimation =
              Tween<double>(begin: currentValue, end: double.parse(newData))
                  .animate(CurvedAnimation(
                      parent: _radialAnimationControllerCoolantTemp,
                      curve: Curves.easeInOutBack));
          _radialAnimationControllerCoolantTemp.forward(
              from: 0); // Starts animation from current value to new value
        });
      }
    });
    _VoltageSubcription =
        databaseRef.child('ReadLiveData/voltage').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _VoltageData) {
        setState(() {
          _VoltageData = newData;
          // Since this is just a display update, no animation control is added here
        });
      }
    });

    _FlowSubscription =
        databaseRef.child('ReadLiveData/flow').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _FlowData) {
        setState(() {
          _FlowData = newData;
          // Since this is just a display update, no animation control is added here
        });
      }
    });

    _IntakeTempSubscription =
        databaseRef.child('ReadLiveData/intake_temp').onValue.listen((event) {
      var newData = event.snapshot.value.toString();
      if (newData != _IntakeTempData) {
        setState(() {
          _IntakeTempData = newData;
          // Update the Tween to start at the current animation value and end at the new data value
          double currentValue = _IntakeTempAnimation.value;
          _IntakeTempAnimation =
              Tween<double>(begin: currentValue, end: double.parse(newData))
                  .animate(CurvedAnimation(
                      parent: _radialAnimationControllerIntakeTemp,
                      curve: Curves.easeInOutBack));
          _radialAnimationControllerIntakeTemp.forward(
              from: 0); // Starts animation from current value to new value
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    // Dispose all the animation controllers
    _radialAnimationControllerEngineSpeed.dispose();
    _radialAnimationControllerVehicleSpeed.dispose();
    _radialAnimationControllerLoad.dispose();
    _radialAnimationControllerIntakeMap.dispose();
    _radialAnimationControllerCoolantTemp.dispose();
    _radialAnimationControllerIntakeTemp.dispose();

    // Unsubscribe from all the Firebase subscriptions
    _enginespeedSubscription?.cancel();
    _vehiclespeedSubscription?.cancel();
    _LoadSubscription?.cancel();
    _CoolantTempSubscription?.cancel();
    _IntakeTempSubscription?.cancel();
    _IntakeMapSubscription?.cancel();
    _FlowSubscription?.cancel();
    _VoltageSubcription?.cancel();

    // Allow the device to rotate again to all orientations when the widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 22, 22, 22),
        child: isLandscape ? buildLandscapeContent() : buildPortraitContent(),
      ),
    );
  }

  Widget buildLandscapeContent() {
    double width = MediaQuery.of(context).size.width / 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(width: width, child: _buildVehicleSpeedLoadGauge()),
        SizedBox(width: width, child: _buildVoltageDisplay()),
        SizedBox(width: width, child: _buildEngineSpeedTempGauge()),
      ],
    );
  }

  Widget buildPortraitContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(child: _buildVehicleSpeedLoadGauge()),
        Expanded(child: _buildVoltageDisplay()), // New addition
        Expanded(child: _buildEngineSpeedTempGauge()),
      ],
    );
  }

  // Widget _buildCurrentTimeDisplay() {
  //   return Container(
  //     color: Colors.black,
  //     alignment: Alignment.center,
  //     child: Column(
  //       // Sử dụng Stack để đặt các widget lên nhau
  //       children: [
  //         // Text nằm trên Positioned
  //         Text(
  //           _timeString,
  //           style: TextStyle(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //           ),
  // //         ),
  //         // Positioned Container
  //         // Positioned(
  //         //   top: 300,
  //         //   right: 0,
  //         //   child: Container(
  //         //     width: 50,
  //         //     height: 200,
  //         //     child: _buildMafMapGauge(),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildMafMapGauge() {
  //   double intakeMap = double.parse(_IntakeMapData);
  //   return Scaffold(
  //     body: Center(
  //       child: SfLinearGauge(
  //         orientation: LinearGaugeOrientation.vertical,
  //         minimum: 0,
  //         maximum: 700,
  //         interval: 100, // Thiết lập thanh dọc
  //         barPointers: [
  //           LinearBarPointer(
  //             value: intakeMap,
  //             animationDuration: 2000,
  //             animationType: LinearAnimationType.bounceOut,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildVoltageDisplay() {
    double voltageValue = double.parse(_VoltageData);
    return SizedBox(
      width: double
          .infinity, // Ensures the SizedBox takes full width of its parent
      height: 400, // Adjust the height as necessary
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 290, // Adjusts the vertical position from the top of the stack
            left:
                109, // Adjusts the horizontal position from the left of the stack
            child: Image.asset(
              'assets/images/battery.png', // Path to the image asset
              width: 35, // Set the width of the image
              height: 35, // Set the height of the image
            ),
          ),
          Positioned(
            top: 330, // Adjusts vertical position for the text
            left: 100, // Adjusts horizontal position for the text
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: <Color>[
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                  ],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                '$voltageValue' 'V',
                style: TextStyle(
                  color: Colors
                      .white, // Base color is white, but ShaderMask overrides this
                  fontSize: 20,
                  fontFamily: 'Roboto Mono', // Now using Roboto Mono
                ),
              ),
            ),
          ),
          Positioned(
            top: 30, // Adjust positioning as necessary
            left: 82, // Adjust positioning as necessary
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: <Color>[Colors.red, Colors.green, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                _timeString,
                style: TextStyle(
                  color: Colors
                      .white, // Base color is white, but ShaderMask applies the gradient
                  fontSize: 30,
                  fontFamily: 'digital7', // Using the digital font
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSpeedLoadGauge() {
    double temperatureData = double.parse(_vehiclespeedData);
    double LoadData = double.parse(_LoadData);
    double intakeMap = double.parse(_IntakeMapData);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 22, 22),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                centerY: 0.5,
                centerX: 0.75,
                radiusFactor: 1.3,
                interval: 20,
                axisLineStyle: AxisLineStyle(
                  thickness: 10,
                  color: Colors.white,
                  dashArray: <double>[1, 3],
                ),
                minimum: 0,
                maximum: 220,
                axisLabelStyle: GaugeTextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontFamily: 'Times',
                ),
                startAngle: 175,
                endAngle: 40,
                pointers: <GaugePointer>[
                  RangePointer(
                    value: _vehicleSpeedAnimation.value,
                    width: 0.06,
                    sizeUnit: GaugeSizeUnit.factor,
                    gradient: const SweepGradient(colors: <Color>[
                      Color.fromARGB(255, 119, 191, 198),
                      Color.fromARGB(255, 19, 230, 216)
                    ], stops: <double>[
                      0.25,
                      0.75
                    ]),
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Vehicle Speed',
                          style: TextStyle(
                              fontFamily: 'Times',
                              fontSize: 17,
                              color: Colors.white),
                        ),
                        Text(
                          '${_vehicleSpeedAnimation.value.toInt()}',
                          style: TextStyle(
                              fontFamily: 'digital7',
                              fontSize: 30,
                              color: Colors.white),
                        ),
                        Text(
                          'Km/h',
                          style: TextStyle(
                              fontFamily: 'Times',
                              fontSize: 17,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    angle: 270,
                    positionFactor: 0.11,
                  ),
                ],
              ),
              RadialAxis(
                centerY: 0.69,
                centerX: 0.35,
                radiusFactor: 0.5,
                startAngle: 270,
                endAngle: 270,
                interval: 10,
                axisLineStyle: AxisLineStyle(
                  thickness: 10,
                  color: Colors.white,
                  dashArray: <double>[1, 2],
                ),
                minimum: 0,
                maximum: 100,
                axisLabelStyle: GaugeTextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 7,
                  fontFamily: 'Times',
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: _LoadAnimation.value,
                    width: 0.15,
                    sizeUnit: GaugeSizeUnit.factor,
                    gradient: const SweepGradient(colors: <Color>[
                      Color.fromARGB(255, 219, 228, 133),
                      Color.fromARGB(255, 114, 226, 28)
                    ], stops: <double>[
                      0.25,
                      0.75
                    ]),
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Load',
                          style: TextStyle(
                              fontFamily: 'Times',
                              fontSize: 12,
                              color: Colors.white),
                        ),
                        Text(
                          '${_LoadAnimation.value.toInt()}%',
                          style: TextStyle(
                              fontFamily: 'Times',
                              fontSize: 11,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    angle: 270,
                    positionFactor: 0.1,
                  ),
                ],
              ),
              RadialAxis(
                centerY: 0.78,
                centerX: 0.89,
                radiusFactor: 0.59,
                startAngle: 270,
                endAngle: 270,
                interval: 25,
                axisLineStyle: AxisLineStyle(
                  thickness: 10,
                  color: Colors.white,
                  dashArray: <double>[1, 3],
                ),
                minimum: 0,
                maximum: 250,
                axisLabelStyle: GaugeTextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 8,
                  fontFamily: 'Times',
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: _IntakeMapAnimation.value,
                    width: 0.12,
                    sizeUnit: GaugeSizeUnit.factor,
                    gradient: const SweepGradient(colors: <Color>[
                      Color.fromARGB(255, 236, 179, 234),
                      Color.fromARGB(255, 184, 81, 235)
                    ], stops: <double>[
                      0.25,
                      0.75
                    ]),
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'MAP',
                          style: TextStyle(
                              fontFamily: 'Times',
                              fontSize: 12,
                              color: Colors.white),
                        ),
                        Text(
                          '${_IntakeMapAnimation.value.toInt()} kPA',
                          style: TextStyle(
                              fontFamily: 'Times',
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    angle: 270,
                    positionFactor: 0.1,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SecondPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineSpeedTempGauge() {
    double speedValue = double.parse(_enginespeedData);
    double coolantTempData = double.parse(_CoolantTempData);
    double intakeTempData = double.parse(_IntakeTempData);
    double flowValue =
        double.parse(_FlowData); // Assumed to be parsed like the other values

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          centerX: 0.21,
          centerY: 0.5,
          radiusFactor: 1.3,
          interval: 500,
          axisLineStyle: AxisLineStyle(
            thickness: 10,
            color: Colors.white,
            dashArray: <double>[1, 5],
          ),
          minimum: 0,
          maximum: 6000,
          axisLabelStyle: GaugeTextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontFamily: 'Times',
          ),
          startAngle: 85,
          endAngle: 325,
          pointers: <GaugePointer>[
            RangePointer(
              value: _engineSpeedAnimation.value,
              width: 0.06,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: const SweepGradient(colors: <Color>[
                Color.fromARGB(255, 157, 199, 147),
                Color.fromARGB(255, 58, 222, 47)
              ], stops: <double>[
                0.25,
                0.75
              ]),
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Engine Speed',
                    style: TextStyle(
                        fontFamily: 'Times', fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    '${_engineSpeedAnimation.value.toInt()}',
                    style: TextStyle(
                        fontFamily: 'digital7',
                        fontSize: 35,
                        color: Colors.white),
                  ),
                  Text(
                    'RPM',
                    style: TextStyle(
                        fontFamily: 'Times', fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              angle: 270,
              positionFactor: 0.12,
            ),
            GaugeAnnotation(
              widget: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/flow_icon.png', // Path to your asset
                    width: 30,
                    height: 30,
                    // Apply color if needed
                  ), // Using an arrow icon
                  SizedBox(width: 5),
                  Text(
                    '$flowValue g/s',
                    style: TextStyle(
                        fontFamily:
                            'Times', // Assuming RobotoMono is set up correctly in your project
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ],
              ),
              angle: 99,
              positionFactor: 0.3,
            ),
          ],
        ),
        RadialAxis(
          centerY: 0.8,
          centerX: 0.52,
          radiusFactor: 0.52,
          startAngle: 270,
          endAngle: 270,
          interval: 20,
          axisLineStyle: AxisLineStyle(
            thickness: 10,
            color: Colors.white,
            dashArray: <double>[1, 5],
          ),
          minimum: -40,
          maximum: 180,
          axisLabelStyle: GaugeTextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 7,
            fontFamily: 'Times',
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: _CoolantTempAnimation.value,
              width: 0.17,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: const SweepGradient(colors: <Color>[
                Color.fromARGB(255, 71, 196, 221),
                Color.fromARGB(255, 235, 29, 29),
              ], stops: <double>[
                0.25,
                0.75
              ]),
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Coolant',
                    style: TextStyle(
                        fontFamily: 'Times', fontSize: 11, color: Colors.white),
                  ),
                  Text(
                    '${coolantTempData.toStringAsFixed(1)}°C',
                    style: TextStyle(
                        fontFamily: 'Times', fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
              angle: 270,
              positionFactor: 0.1,
            ),
          ],
        ),
        RadialAxis(
            centerY: 0.455,
            centerX: 0.68,
            radiusFactor: 0.52,
            startAngle: 270,
            endAngle: 270,
            interval: 40,
            axisLineStyle: AxisLineStyle(
              thickness: 10,
              color: Colors.white,
              dashArray: <double>[1, 5],
            ),
            minimum: -40,
            maximum: 200,
            axisLabelStyle: GaugeTextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 6,
              fontFamily: 'Times',
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: _IntakeTempAnimation.value,
                width: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
                gradient: const SweepGradient(colors: <Color>[
                  Color.fromARGB(255, 110, 219, 231),
                  Color.fromARGB(255, 210, 74, 10)
                ], stops: <double>[
                  0.25,
                  0.75
                ]),
              )
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Intake',
                      style: TextStyle(
                          fontFamily: 'Times',
                          fontSize: 11,
                          color: Colors.white),
                    ),
                    Text(
                      '${intakeTempData.toStringAsFixed(1)}°C',
                      style: TextStyle(
                          fontFamily: 'Times',
                          fontSize: 11,
                          color: Colors.white),
                    ),
                  ],
                ),
                angle: 270,
                positionFactor: 0.1,
              ),
            ]),
      ],
    );
  }
}
