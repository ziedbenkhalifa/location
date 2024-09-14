import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:malocation/pages/LocaPage.dart';

// Modèle Voiture
class Voiture {
  final String matricule;
  final String marque;
  final String couleur;
  final String type;
  final bool disponibilite;
  final String imageUrl;
  final double prixParJour;

  Voiture({
    required this.matricule,
    required this.marque,
    required this.couleur,
    required this.type,
    required this.disponibilite,
    required this.imageUrl,
    required this.prixParJour,
  });

  factory Voiture.fromJson(Map<String, dynamic> json) {
    return Voiture(
      matricule: json['matricule'],
      marque: json['marque'],
      couleur: json['couleur'],
      type: json['type'],
      disponibilite: json['disponibilite'] == 1,
      imageUrl: json['image_url'],
      prixParJour: json['prix_par_jour'].toDouble(),
    );
  }
}

// Page principale avec la liste des voitures
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Voiture> voitures = [];
  final Map<String, bool> _likedCars = {};
  String? clientId;

  @override
  void initState() {
    super.initState();
    getClientId().then((id) {
      setState(() {
        clientId = id;
      });
      fetchVoitures();
    });
  }

  Future<String?> getClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> fetchVoitures() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.14:3007/voitures'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          voitures = data.map((json) => Voiture.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load voitures');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur de chargement des voitures',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> updateLike(String carId) async {
    if (clientId != null) {
      final url = 'http://192.168.1.14:3007/like';
      final isLiked = _likedCars[carId] ?? false;

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'clientId': clientId!,
            'carId': carId,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _likedCars[carId] = !isLiked; // Inverser le statut de like
          });
          Fluttertoast.showToast(
            msg: isLiked ? 'Like retiré' : 'Voiture likée',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: isLiked ? Colors.grey : Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Erreur lors de l\'action',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Erreur de connexion au serveur',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Client non connecté',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Redirection vers la page de location
  void goToLocaPage(String matricule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocaPage(
          matriculeVoiture: matricule,
          clientId: clientId!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voitures'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: voitures.length,
          itemBuilder: (context, index) {
            final voiture = voitures[index];
            final isLiked = _likedCars[voiture.matricule] ?? false;

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: voiture.disponibilite ? Colors.white : Color(0xFFD1A0A0), // Couleur différente si indisponible
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      voiture.imageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  voiture.marque,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Couleur: ${voiture.couleur}',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                ),
                                Text(
                                  'Type: ${voiture.type}',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                ),
                                Text(
                                  'Prix par jour: ${voiture.prixParJour.toStringAsFixed(2)} DT',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                ),
                                if (!voiture.disponibilite)
                                  Text(
                                    'Bientôt disponible',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              voiture.disponibilite
                                  ? ElevatedButton(
                                onPressed: () {
                                  goToLocaPage(voiture.matricule); // Naviguer vers la page de location
                                },
                                child: Text('Louer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              )
                                  : SizedBox.shrink(),
                              Container(
                                margin: EdgeInsets.only(left: 9),
                                padding: EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    updateLike(voiture.matricule); // Gestion des likes
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
