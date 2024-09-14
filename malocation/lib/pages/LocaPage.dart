import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart'; // Import pour le formatage des dates

// Modèle Voiture (déjà défini dans le fichier précédent)
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

// Nouvelle page de location
class LocaPage extends StatefulWidget {
  final String matriculeVoiture; // ID de la voiture reçu depuis la page Home
  final String clientId; // ID du client (non affiché, mais utilisé)

  LocaPage({required this.matriculeVoiture, required this.clientId});

  @override
  _LocaPageState createState() => _LocaPageState();
}

class _LocaPageState extends State<LocaPage> {
  late Voiture voiture;
  bool isLoading = true; // Indicateur de chargement
  DateTime? _dateDebut;
  DateTime? _dateFin;

  @override
  void initState() {
    super.initState();
    fetchVoitureDetails(); // Charger les détails de la voiture
  }

  // Récupérer les détails de la voiture via l'API
  Future<void> fetchVoitureDetails() async {
    final url = 'http://192.168.1.14:3007/voiture/${widget.matriculeVoiture}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          voiture = Voiture.fromJson(data); // Stocker la voiture dans l'état
          isLoading = false; // Arrêter le chargement
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Erreur lors du chargement des détails de la voiture',
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
  }

  // Calculer le prix total
  double _calculateTotalPrice() {
    if (_dateDebut != null && _dateFin != null) {
      final duration = _dateFin!.difference(_dateDebut!);
      final days = duration.inDays + 1; // +1 pour inclure les deux dates
      return days * voiture.prixParJour;
    }
    return 0.0;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDateRange: _dateDebut != null && _dateFin != null
          ? DateTimeRange(start: _dateDebut!, end: _dateFin!)
          : null,
    );

    if (pickedRange != null && pickedRange.start != pickedRange.end) {
      setState(() {
        _dateDebut = pickedRange.start;
        _dateFin = pickedRange.end;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_dateDebut == null || _dateFin == null) {
      Fluttertoast.showToast(
        msg: 'Veuillez sélectionner la plage de dates.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final url = 'http://192.168.1.14:3007/create_location'; // Remplacez par l'URL de votre API

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'voiture_matricule': voiture.matricule,
          'date_debut': DateFormat('yyyy-MM-dd').format(_dateDebut!),
          'date_fin': DateFormat('yyyy-MM-dd').format(_dateFin!),
          'client_id': widget.clientId,
          'prix_par_jour': voiture.prixParJour,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        Fluttertoast.showToast(
          msg: 'Location confirmée. ID: ${responseData['locationId']}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context); // Retourner à la liste des voitures après confirmation
      } else {
        Fluttertoast.showToast(
          msg: 'Erreur lors de la confirmation de la location',
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
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text('Louer ${isLoading ? '' : voiture.marque}'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  voiture.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marque: ${voiture.marque}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Matricule: ${voiture.matricule}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.color_lens, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Couleur: ${voiture.couleur}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Type: ${voiture.type}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prix par jour: ${voiture.prixParJour.toStringAsFixed(2)} DT',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Bouton de sélection de date
                  ElevatedButton(
                    onPressed: _selectDateRange,
                    child: Text(
                      _dateDebut == null || _dateFin == null
                          ? 'Choisir la période'
                          : 'Période sélectionnée: ${DateFormat('yyyy-MM-dd').format(_dateDebut!)} à ${DateFormat('yyyy-MM-dd').format(_dateFin!)}',
                    ),
                  ),
                  SizedBox(height: 16),
                  // Affichage du prix total
                  if (_dateDebut != null && _dateFin != null)
                    Text(
                      'Prix total: ${totalPrice.toStringAsFixed(2)} DT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  SizedBox(height: 32),
                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _confirmBooking,
                        child: Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Annuler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
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
  }
}
