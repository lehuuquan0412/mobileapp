import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'first_page.dart';
import 'signup_page.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                      child: Image.asset(
                        'assets/icons/logoBK.png',
                        width: 150,
                        height: 130,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text('Welcome Back!',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_errorMessage != null)
                          Expanded(
                            child: Text(_errorMessage!,
                                style: TextStyle(
                                    color: Colors.redAccent, fontSize: 14),
                                textAlign: TextAlign.left),
                          ),
                        TextButton(
                          onPressed: _sendPasswordResetEmail,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _attemptLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 9, 9, 9),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Sign In',
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage())),
                      child: Text('No account? Sign up here',
                          style: TextStyle(
                              fontFamily: 'Times',
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 27, // Adjust the size as needed
                      ),
                      label: Text('Sign in with Google',
                          style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _signInWithFacebook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      icon: Icon(FontAwesomeIcons.facebook,
                          size: 30, color: Colors.white),
                      label: Text('Sign in with Facebook',
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      _login();
    }
  }

  void _login() async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FirstPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please verify your email address to proceed.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Incorrect password or email';
      });
    }
  }

  void _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.user != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FirstPage()));
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google: $e';
      });
    }
  }

  void _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.user != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FirstPage()));
        }
      } else if (result.status == LoginStatus.cancelled) {
        setState(() {
          _errorMessage = 'Facebook login cancelled by user.';
        });
      } else if (result.status == LoginStatus.failed) {
        setState(() {
          _errorMessage = 'Facebook login failed: ${result.message}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Facebook: $e';
      });
    }
  }

  void _sendPasswordResetEmail() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage =
            "Please enter your email address to reset your password.";
      });
      return;
    }
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      setState(() {
        _errorMessage =
            "Password reset email sent. Check your email to reset your password.";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error sending password reset email: ${e.toString()}";
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
