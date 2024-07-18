import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlActuatorsPage extends StatefulWidget {
  @override
  _ControlActuatorsPageState createState() => _ControlActuatorsPageState();
}

class _ControlActuatorsPageState extends State<ControlActuatorsPage> {
  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref('commands/command');

  Future<void> updateCommand(String command) {
    return databaseRef.set(command).then((_) {
      print('Command updated to $command');
    }).catchError((error) {
      print('Failed to update command: $error');
    });
  }

  @override
  void dispose() {
    updateCommand('h').then((_) {
      print("Command set to 'h' upon exiting the page.");
    }).catchError((error) {
      print("Failed to set command on exit: $error");
    });

    super.dispose();
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
          'Control Actuators',
          style: TextStyle(
            color: const Color.fromARGB(255, 237, 230, 229),
            fontFamily: 'Times',
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Height of the divider
          child: Container(
            color: Colors.grey, // Color of the divider line
            height: 2.0, // Thickness of the divider line
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/icons/fan.png', width: 140, height: 140),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => updateCommand('a'),
                  child: Text('Turn On Coolant Fan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Times')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 68, 180, 70),
                    fixedSize: Size(180, 60),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => updateCommand('b'),
                  child: Text('Turn Off Coolant Fan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 254, 253, 253),
                          fontSize: 18,
                          fontFamily: 'Times')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 185, 61, 42),
                    fixedSize: Size(180, 60),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Image.asset('assets/icons/throttle.png', width: 140, height: 140),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => updateCommand('c'),
                  child: Text('Open Throttle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Times')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 68, 180, 70),
                    fixedSize: Size(180, 60),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => updateCommand('d'),
                  child: Text('Close Throttle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 247, 245, 245),
                          fontSize: 18,
                          fontFamily: 'Times')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 185, 61, 42),
                    fixedSize: Size(180, 60),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Image.asset('assets/icons/relay.png', width: 140, height: 140),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => updateCommand('e'),
                  child: Text('Open Glow Relay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Times')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 68, 180, 70),
                    fixedSize: Size(180, 60),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => updateCommand('f'),
                  child: Text('Close Glow Relay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Times')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 185, 61, 42),
                    fixedSize: Size(180, 60),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
