import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:malocation/auth.dart';

class Crcompte extends StatefulWidget {
  const Crcompte({Key? key}) : super(key: key);

  @override
  State<Crcompte> createState() => _CrcompteState();
}

class _CrcompteState extends State<Crcompte> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _register() async {
    if (emailController.text.isEmpty ||
        nomController.text.isEmpty ||
        prenomController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Remplir tous les champs",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    var regBody = {
      "nom": nomController.text,
      "prenom": prenomController.text,
      "email": emailController.text,
      "password": passwordController.text,
    };

    var response = await http.post(
      Uri.parse('http://192.168.1.14:3007/clients'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(regBody),
    );

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status'] == false) {
      String errorMessage = jsonResponse['error'];
      if (errorMessage == 'L\'email est déjà utilisé.') {
        Fluttertoast.showToast(
          msg: "Email existe déjà",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Erreur d'enregistrement",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Auth()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/cont.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: 70),
            width: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/registre.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'images/create2.png',
                    height: 90,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'E-mail',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextField(
                      controller: nomController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nom',
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
                      controller: prenomController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Prénom',
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
                      controller: passwordController,
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
                    onPressed: _register,
                    child: const Text('Enregistrer'),
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
                        'Déjà créé ?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Auth()));
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
                        child: const Text('Se connecter', style: TextStyle(fontSize: 12)),
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
