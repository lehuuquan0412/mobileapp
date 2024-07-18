import 'package:flutter/material.dart';
import 'second_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomepage.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: screenWidth * 0.08, // Dynamic positioning
              top: screenHeight * 0.11, // Dynamic positioning
              child: Text(
                'Welcome',
                style: TextStyle(
                  color: Color.fromRGBO(231, 228, 228, 0.875),

                  fontSize: screenHeight * 0.09, // Dynamic sizing
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      // Base shadow
                      blurRadius: 10.0,
                      color:
                          Color.fromARGB(255, 247, 244, 244).withOpacity(0.5),
                      offset: Offset(5.0, 5.0),
                    ),
                    Shadow(
                      // Additional shadow for more depth
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(-5.0, -5.0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: screenWidth * 0.08, // Dynamic positioning
              top: screenHeight * 0.21, // Dynamic positioning
              child: Text(
                'Driver',
                style: TextStyle(
                  color: Color.fromRGBO(231, 228, 228, 0.875),
                  fontSize: screenHeight * 0.09, // Dynamic sizing
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: const Color.fromARGB(255, 228, 223, 223)
                          .withOpacity(0.5),
                      offset: Offset(5.0, 5.0),
                    ),
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(-5.0, -5.0),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.35,
              left: screenWidth * 0.01, // 10% padding from the left
              right: screenWidth * 0.01, // 10% padding from the right
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Discover our OBD-II mobile app smart diagnostics and vehicle monitoring. Help to maintain your vehicle health and optimizing your driving experience',
                  style: TextStyle(
                    color: Color.fromARGB(255, 192, 189, 189),
                    fontSize:
                        screenHeight * 0.017, // Size based on screen height
                    fontStyle: FontStyle.italic,
                    fontFamily: "PlayfairDisplay-Italic",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              right: screenWidth * 0.02,
              bottom: screenHeight * 0.05,
              child: SlideToUnlockButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class SlideToUnlockButton extends StatefulWidget {
  @override
  _SlideToUnlockButtonState createState() => _SlideToUnlockButtonState();
}

class _SlideToUnlockButtonState extends State<SlideToUnlockButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  late AnimationController _animationController; // Controller for the animation
  late Animation<double> _animation; // Animation variable

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Define the animation
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }
          });

    _animationController.forward(); // Start the animation
  }

  @override
  void dispose() {
    _animationController.dispose(); // Properly dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragPosition += details.primaryDelta!;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragPosition >= 100) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondPage()),
          ).then((_) {
            // Reset drag position when returning from the second page
            setState(() {
              _dragPosition = 0;
            });
          });
        } else {
          setState(() {
            _dragPosition = 0;
          });
        }
      },
      child: Container(
        width: 250,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.black.withOpacity(0.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: _dragPosition,
              child: FadeTransition(
                opacity: _animation, // Use the animation for opacity
                child: Container(
                  width: 230,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      'Slide To Discover App',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 201, 195, 195),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              child: Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
