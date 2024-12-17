import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      userName = user?.displayName;
      isLoading = false;
    });
  }

  Widget _buildStartMessage() {
    return Column(
      children: [
        Text(
          'Hello, ${userName?.split(' ').first ?? 'User'} !',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CustomColors.primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'What are we cooking today?',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: CustomColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/occasion');
      },
      child: const Text(
        "Let's Begin!",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStartMessage(),
          const SizedBox(height: 30),
          _buildStartButton(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Yummy',
            style: TextStyle(color: CustomColors.textColor),
          ),
          backgroundColor: Color.fromRGBO(255, 134, 64, 0.85),
          elevation: 0,
          iconTheme: IconThemeData(color: CustomColors.textColor),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        backgroundColor: Colors.grey[200],
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: _buildContent(context),
              ),
      ),
    );
  }
}
