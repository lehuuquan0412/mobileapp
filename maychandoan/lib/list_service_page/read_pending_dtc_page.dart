import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReadPendingDTCPage extends StatefulWidget {
  @override
  _ReadPendingDTCPageState createState() => _ReadPendingDTCPageState();
}

class _ReadPendingDTCPageState extends State<ReadPendingDTCPage> {
  final databaseRef = FirebaseDatabase.instance.ref('freezeErrorCodes');
  List<String> dtcCodes = [];
  bool showReadButton = true;
  bool isBlinking = true;

  @override
  void initState() {
    super.initState();
    _startBlinking(); // Start blinking as soon as the widget is built.
  }

  _startBlinking() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          isBlinking = !isBlinking;
        });
      }
      return showReadButton; // Continue blinking only if the Read text is visible.
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
          'Pending Fault Code',
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
          children: [
            if (showReadButton)
              InkWell(
                onTap: readData,
                child: AnimatedOpacity(
                  opacity: isBlinking ? 1.0 : 0.0,
                  duration: Duration(seconds: 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search,
                          color: Color.fromARGB(255, 113, 151, 191), size: 30),
                      SizedBox(height: 10),
                      Text(
                        'TAP HERE TO READ\nPENDING TROUBLE CODE',
                        style: TextStyle(
                            color: Color.fromARGB(255, 113, 151, 191),
                            fontSize: 18,
                            fontFamily: "Times"),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            if (dtcCodes.isNotEmpty)
              Expanded(
                  child: ListView.builder(
                itemCount: dtcCodes.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: index % 2 == 0 ? Colors.grey[850] : Colors.grey[800],
                    child: ListTile(
                      leading: Icon(Icons.warning,
                          color: Color.fromARGB(255, 209, 219, 23)),
                      title: Text(dtcCodes[index],
                          style: TextStyle(
                              fontFamily: 'Times', color: Colors.white)),
                      onTap: () {
                        // Extract the DTC code part before the dash
                        String code = dtcCodes[index].split(' -')[0];
                        _showDtcDetail(code);
                      },
                    ),
                  );
                },
              )),
            if (dtcCodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Notes: Tap on Fault Code to show full name, description, symptoms and repair tips",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontFamily: "Times",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (!showReadButton && dtcCodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.delete, size: 25, color: Colors.white),
                  label: Text('CLEAR STORED TROUBLE CODE',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: Colors.white)),
                  onPressed: clearData,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 197, 54, 54),
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20), // Adjusted padding
                      textStyle: TextStyle(fontSize: 20) // Corrected text size
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDtcDetail(String code) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('dtc_codes')
        .doc(code)
        .get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(data['name'] ?? 'No Name'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Description: ${data['description'] ?? 'No Description'}'),
                  SizedBox(height: 10),
                  Text('Symptoms: ${data['symptoms'] ?? 'No Symptoms'}'),
                  SizedBox(height: 20),
                  Text('Repair Tips: ${data['repair tips'] ?? 'Repair Tips'}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No data found for code $code',
            style: TextStyle(
                fontFamily: 'Times', // Specify the font family
                fontSize: 18, // Specify the font size
                color: Colors.white // Optional: Change text color
                )),
      ));
    }
  }

  String extractDTCCode(String fullCode) {
    // Check if the code follows the expected pattern and remove the format
    if (fullCode.startsWith('{FreezeDTC: ') && fullCode.endsWith('}')) {
      return fullCode
          .substring(12, fullCode.length - 1)
          .trim(); // Remove the prefix and trim any extra spaces
    }
    return fullCode; // Return the original string if it does not match expected format
  }

  void readData() {
    setState(() {
      isBlinking = false; // Stop blinking when user taps to read data
    });
    databaseRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        Set<String> uniqueCodes = Set<String>();
        List<Future<String>> futures = values.entries.map((entry) {
          String code = extractDTCCode(entry.value.toString());
          if (uniqueCodes.add(code)) {
            return FirebaseFirestore.instance
                .collection('dtc_codes')
                .doc(code)
                .get()
                .then((DocumentSnapshot doc) {
              if (doc.exists && doc.data() != null) {
                Map<String, dynamic> data =
                    doc.data() as Map<String, dynamic>? ?? {};
                return '$code - ${data['name'] ?? 'Unknown'}';
              } else {
                return code;
              }
            });
          } else {
            return Future.value('$code - Duplicate');
          }
        }).toList();

        Future.wait(futures).then((List<String> results) {
          setState(() {
            dtcCodes = results
                .where((result) => !result.endsWith('Duplicate'))
                .toList();
            showReadButton = false; // Hide Read text after data is fetched
          });
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error processing data: $e')));
        });
      } else {
        setState(() {
          dtcCodes = [];
          showReadButton = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No Pending DTC Found',
              style: TextStyle(
                  fontFamily: 'Times', // Specify the font family
                  fontSize: 18, // Specify the font size
                  color: Colors.white // Optional: Change text color
                  )),
          backgroundColor: Colors.black, // Optional: Change background color
        ));
      }
    }).catchError((error) {
      print('Failed to read data: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to read data: $error')));
    });
  }

  void clearData() {
    databaseRef.remove().then((_) {
      print('Data removed successfully from Firebase.');
      setState(() {
        dtcCodes = [];
        showReadButton = true; // Show Read text again to allow re-fetching
        isBlinking = true; // Restart blinking when the text is shown again
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('All Pending DTC have been cleared from Firebase.',
            style: TextStyle(
                fontFamily: 'Times', // Specify the font family
                fontSize: 18, // Specify the font size
                color: Colors.white // Optional: Change text color
                )),
        backgroundColor: Colors.black, // Optional: Change background color
      ));
    }).catchError((error) {
      print('Failed to remove data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove data: $error')));
    });
  }
}
