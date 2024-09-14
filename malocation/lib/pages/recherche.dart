import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Define the Voiture class
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

// Define the Recherche class
class Recherche extends StatefulWidget {
  @override
  _RechercheState createState() => _RechercheState();
}

class _RechercheState extends State<Recherche> {
  List<Voiture> voitures = [];
  final Map<String, bool> _likedCars = {}; // Track liked status for each car
  String? clientId; // To store the client ID

  TextEditingController _marqueController = TextEditingController();
  TextEditingController _prixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getClientId().then((id) {
      setState(() {
        clientId = id;
      });
    });
  }

  Future<String?> getClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> searchVoitures() async {
    final marque = _marqueController.text;
    final maxPrix = _prixController.text;

    try {
      final response = await http.get(Uri.parse('http://192.168.1.14:3007/search?marque=$marque&maxPrix=$maxPrix'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          Fluttertoast.showToast(
            msg: 'Aucune voiture disponible pour ces critères',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          setState(() {
            voitures = data.map((json) => Voiture.fromJson(json)).toList();
          });
        }
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
            _likedCars[carId] = !isLiked; // Toggle the liked status
          });
          Fluttertoast.showToast(
            msg: isLiked ? 'Like removed' : 'Car liked',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: isLiked ? Colors.grey : Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to update like',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error connecting to server',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Client not logged in',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> louerVoiture(String carId) async {
    if (clientId != null) {
      final url = 'http://192.168.1.14:3007/louer';
      final body = jsonEncode({
        'clientId': clientId!,
        'carId': carId,
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: 'Location réussie',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Erreur lors de la location',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
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
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Client not logged in',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _marqueController,
                    decoration: InputDecoration(
                      labelText: 'Marque',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _prixController,
                    decoration: InputDecoration(
                      labelText: 'Prix maximum',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchVoitures,
                ),
              ],
            ),
          ),
          Expanded(
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
                  color: voiture.disponibilite ? Colors.white : Color(0xFFD1A0A0),
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
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      'Type: ${voiture.type}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      'Prix par jour: ${voiture.prixParJour.toStringAsFixed(2)} DT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    if (!voiture.disponibilite)
                                      Text(
                                        'Ça sera très bientôt disponible',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  voiture.disponibilite
                                      ? ElevatedButton(
                                    onPressed: () {
                                      louerVoiture(voiture.matricule);
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
                                        updateLike(voiture.matricule);
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
        ],
      ),
    );
  }
}
