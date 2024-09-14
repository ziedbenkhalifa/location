import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';
import 'package:malocation/pages/home.dart';
import 'package:malocation/pages/historique.dart';
import 'package:malocation/pages/recherche.dart';
import 'package:malocation/pages/profile.dart';
import 'package:malocation/pages/crudclient.dart';
import 'package:malocation/pages/crudlocation.dart';
import 'package:malocation/pages/crudvoiture.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? role = prefs.getString('role');
  runApp(MyApp(role: role));
}

class MyApp extends StatelessWidget {
  final String? role;

  const MyApp({Key? key, this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: role == null ? Auth() : SplashScreen(role: role!),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String role;

  const SplashScreen({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainApp(role: role)),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(), // You can customize this as needed
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final String role;

  const MainApp({Key? key, required this.role}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentIndex = 0;

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    _configureScreens();
  }

  void _configureScreens() {
    if (widget.role == 'client') {
      screens = [
        Home(),
        Recherche(),
        Historique(),
        Profile(),
      ];
    } else if (widget.role == 'admin') {
      screens = [
        CrudClientPage(),  // Ici on ajoute la page CRUD pour les clients
        LocationsScreen(),
        Crudvoiture(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() => currentIndex = index),
        currentIndex: currentIndex,
        backgroundColor: Color(0xFF3FB7AB),
        unselectedItemColor: Color(0xFFD8AEAE),
        selectedItemColor: Color(0xFFD8AEAE),
        selectedFontSize: 20,
        unselectedFontSize: 15,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: widget.role == 'client'
            ? const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Historique"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ]
            : const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clients"),
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: "Locations"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Voitures"),
        ],
      ),
    );
  }
}
