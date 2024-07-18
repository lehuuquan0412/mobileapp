import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchDTCPage extends StatefulWidget {
  @override
  _SearchDTCPageState createState() => _SearchDTCPageState();
}

class _SearchDTCPageState extends State<SearchDTCPage> {
  final TextEditingController _searchController = TextEditingController();
  DocumentSnapshot? _currentDocument;

  void _searchDTC(String dtcCode) {
    FirebaseFirestore.instance
        .collection('dtc_codes')
        .doc(dtcCode)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          _currentDocument = document;
        });
      } else {
        setState(() {
          _currentDocument = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No data found for this DTC code.')));
      }
    }).catchError((e) {
      print('Error fetching document: $e');
    });
  }

  Future<List<String>> searchDtcCodes(String query) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot snapshot = await firestore
          .collection('dtc_codes')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: query)
          .where(FieldPath.documentId, isLessThan: query + 'z')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
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
          'Search DTC Information',
          style: TextStyle(
            color: const Color.fromARGB(255, 237, 230, 229),
            fontFamily: 'Times',
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                } else {
                  return await searchDtcCodes(textEditingValue.text);
                }
              },
              onSelected: (String selection) {
                _searchDTC(selection);
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Enter Fault Code',
                    labelStyle: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 22),
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(172, 188, 185, 190), width: 5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 165, 145, 185), width: 5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: Container(
                      width: 360,
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 222, 218, 218),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 177, 172, 172)
                                .withOpacity(0.7),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option,
                                style: TextStyle(
                                    fontFamily: "Times",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 159, 28, 28))),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                children: _currentDocument != null ? _buildDocumentView() : [],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Note: Remember to capitalize the first letter of the error code",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 17,
                  fontFamily: "Times",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDocumentView() {
    List<Widget> list = [
      SizedBox(height: 20),
    ];
    list.add(_buildSectionContainer("Name", _getDataField('name', 'No name')));
    list.add(_buildSectionContainer(
        "Description", _getDataField('description', 'No description')));
    list.add(_buildSectionContainer(
        "Symptoms", _getDataField('symptoms', 'No symptoms')));
    list.add(_buildSectionContainer(
        "Repair Tips", _getDataField('repair tips', 'No repair tips')));
    return list;
  }

  Widget _buildSectionContainer(String title, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromARGB(255, 238, 240, 240))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSectionTitle(title), _buildTextItem(text)],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Color.fromARGB(255, 229, 170, 75),
        fontSize: 18,
        fontFamily: 'Times',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextItem(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  String _getDataField(String field, String defaultValue) {
    if (_currentDocument != null &&
        _currentDocument!.data() is Map<String, dynamic>) {
      var data = _currentDocument!.data() as Map<String, dynamic>;
      return data[field] ?? defaultValue;
    }
    return defaultValue;
  }
}
