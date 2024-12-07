import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _animation!,
      child: Column(
        children: [
          Image.asset(
            'assets/logo_black.png',
            height: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return FadeTransition(
      opacity: _animation!,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: const Text(
          "Let's Cook!",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            ' Login',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(),
        Text(
          'Yummy',
          style: TextStyle(
            fontSize: 50,
            fontFamily: AppFonts.bubblebodyNeue,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 40),
        _buildStartButton(),
        const SizedBox(height: 20),
        _buildFooter(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.primaryColor, // Cor principal
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: _buildContent(),
        ),
      ),
    );
  }
}
