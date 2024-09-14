import 'package:flutter/material.dart';
import 'package:malocation/pages/home.dart'; // Ensure you have the correct path
import 'package:malocation/crcompte.dart';
import 'package:malocation/pages/splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String loginUrl = 'http://192.168.1.14:3007/login';

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Veuillez remplir tous les champs',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    var loginBody = {
      "email": email,
      "password": password,
    };

    try {
      var response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginBody),
      );

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['message'] == 'Connexion réussie') {
        String role = jsonResponse['role'];
        String userId = jsonResponse['userId'].toString();
        String token = jsonResponse['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', role);
        await prefs.setString('userId', userId);
        await prefs.setString('token', token);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreen(role: role)),
        );
      } else {
        Fluttertoast.showToast(
          msg: jsonResponse['error'] ?? 'Erreur lors de la connexion',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur de connexion',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/blogo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: 180),
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFA5DCA6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'images/liche.png',
                    height: 80,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Utilisateur',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Mot de passe',
                        prefixIcon: Icon(
                          Icons.password_sharp,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Se connecter'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nouveau compte?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Crcompte()));
                        },
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(100, 30)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                        ),
                        child: const Text('Créer un compte', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
