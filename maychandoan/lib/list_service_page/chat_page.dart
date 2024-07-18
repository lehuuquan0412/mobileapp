import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _userInput = TextEditingController();
  static const apiKey =
      'AIzaSyBJRSVoiCBXbHAs85jBzRtBI3ubiG03g3s'; // Replace with your actual API keysd
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];
  bool _isResponding = false;

  Future<void> sendMessage() async {
    final message = _userInput.text;
    _userInput.clear();
    setState(() {
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
      _isResponding = true;
    });
    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    setState(() {
      _messages.add(Message(
          isUser: false, message: response.text ?? "", date: DateTime.now()));
      _isResponding = false;
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
          'Chat With Bot Help',
          style: TextStyle(
            color: const Color.fromARGB(255, 237, 230, 229),
            fontFamily: 'Times',
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Messages(
                          isUser: message.isUser,
                          message: message.message,
                          date: DateFormat('HH:mm').format(message.date));
                    })),
            if (_isResponding)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircularProgressIndicator(color: Colors.deepPurple),
                    SizedBox(width: 10),
                    Text('Gemini is responding...',
                        style: TextStyle(color: Colors.white))
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        label: Text('Enter Your Message',
                            style: TextStyle(color: Colors.white)),
                        fillColor: Colors.grey[900],
                        filled: true,
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      padding: EdgeInsets.all(12),
                      iconSize: 30,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueAccent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(CircleBorder())),
                      onPressed: sendMessage,
                      icon: Icon(Icons.send))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  const Messages(
      {super.key,
      required this.isUser,
      required this.message,
      required this.date});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15)
          .copyWith(left: isUser ? 100 : 10, right: isUser ? 10 : 100),
      decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[850],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: isUser ? Radius.circular(10) : Radius.zero,
              topRight: Radius.circular(10),
              bottomRight: isUser ? Radius.zero : Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
                fontSize: 14, // Reduced font size
                color: isUser ? Colors.white : Colors.white70),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }
}
