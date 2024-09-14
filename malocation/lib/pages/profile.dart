import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:malocation/auth.dart'; // Importez votre page Auth pour la redirection

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? clientData;
  List<dynamic> likedCars = [];
  String? clientId;

  @override
  void initState() {
    super.initState();
    _fetchClientData();
  }

  Future<void> _fetchClientData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      clientId = prefs.getString('userId');

      if (clientId != null) {
        final response = await http.get(Uri.parse('http://192.168.1.14:3007/client/$clientId'));

        if (response.statusCode == 200) {
          setState(() {
            clientData = json.decode(response.body);
          });
          _fetchLikedCars();
        } else {
          Fluttertoast.showToast(
            msg: 'Erreur lors du chargement des données du client',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Erreur de connexion',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _fetchLikedCars() async {
    try {
      if (clientId != null) {
        final response = await http.get(Uri.parse('http://192.168.1.14:3007/client/$clientId/liked-cars'));

        if (response.statusCode == 200) {
          setState(() {
            likedCars = json.decode(response.body);
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Erreur lors du chargement des voitures aimées',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Erreur de connexion',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _confirmLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation de Déconnexion'),
          content: Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _logout(); // Perform logout
              },
              child: Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('token'); // Remove the token as well, if applicable

      // Navigate to the Auth page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Auth()), // Replace with your Auth page widget
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la déconnexion',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: 'Impossible d\'ouvrir l\'URL',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = clientData != null
        ? '${clientData!['nom']![0]}${clientData!['prenom']![0]}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white), // Set color here
            onPressed: _confirmLogout, // Show confirmation dialog
          ),
        ],
      ),
      body: clientData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal,
                  child: Text(
                    initials,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nom: ${clientData!['nom'] ?? 'Non disponible'}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Email: ${clientData!['email'] ?? 'Non disponible'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Liked Cars
            Text(
              'Voitures aimées:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: likedCars.length,
                itemBuilder: (context, index) {
                  final car = likedCars[index];
                  final price = car['prix_par_jour'] is num
                      ? (car['prix_par_jour'] as num).toStringAsFixed(2)
                      : '0.00';

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              car['image_url'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(car['marque'] ?? 'Non disponible'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Prix par jour: $price DT'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Company Contact Info
            Text(
              'Contact de l\'entreprise:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.phone, color: Colors.green), // Set color here
                  onPressed: () => _launchURL('tel:+1234567890'), // Replace with actual phone number
                ),
                IconButton(
                  icon: Icon(Icons.email, color: Colors.grey), // Set color here
                  onPressed: () => _launchURL('mailto:contact@entreprise.com'), // Replace with actual email
                ),
                IconButton(
                  icon: Icon(Icons.facebook, color: Colors.blue), // Set color here
                  onPressed: () => _launchURL('https://www.facebook.com/entreprise'), // Replace with actual Facebook URL
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
