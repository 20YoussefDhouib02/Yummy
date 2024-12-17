import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  Widget _buildGoogleSignInButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset('assets/google_logo.png', height: 24),
      label: Text(
        'Continue with Google',
        style: TextStyle(color: CustomColors.textColor, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: CustomColors.textColor,
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () async {
        final user = await _authService.signInWithGoogle();
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login with Google failed. Please try again.')),
          );
        }
      },
    );
  }

  // Widget _buildAppleSignInButton(BuildContext context) {
  //   return ElevatedButton.icon(
  //     icon: const Icon(Icons.apple, size: 24),
  //     label: const Text(
  //       'Continuar com Apple',
  //       style: TextStyle(color: Colors.white, fontSize: 16),
  //     ),
  //     style: ElevatedButton.styleFrom(
  //       foregroundColor: Colors.white,
  //       backgroundColor: Colors.black,
  //       minimumSize: const Size(double.infinity, 50),
  //       side: const BorderSide(color: Colors.black),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(30),
  //       ),
  //     ),
  //     onPressed: () async {
  //       final user = await _authService.signInWithApple();
  //       if (user != null) {
  //         Navigator.pushReplacementNamed(context, '/home');
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Falha no login com Apple. Tente novamente.')),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account?',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            ' Register',
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

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Login',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 40),
          _buildGoogleSignInButton(context),
          // const SizedBox(height: 20),
          // _buildAppleSignInButton(context),
          const SizedBox(height: 20),
          _buildFooter(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.primaryColor,
      body: Center(
        child: _buildContent(context),
      ),
    );
  }
}
