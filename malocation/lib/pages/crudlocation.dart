import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    title: 'Locations CRUD',
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: LocationsScreen(),
  ));
}

class LocationsScreen extends StatefulWidget {
  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  late Future<List<Location>> _locations;
  late Future<List<Voiture>> _voitures;
  late Future<List<Client>> _clients;

  @override
  void initState() {
    super.initState();
    _locations = fetchLocations();
    _voitures = fetchVoitures();
    _clients = fetchClients();
  }

  Future<List<Location>> fetchLocations() async {
    final response = await http.get(Uri.parse('http://192.168.1.14:3007/locations'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Location.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  Future<void> createLocation(Location location) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.14:3007/locations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'voiture_matricule': location.voitureMatricule,
        'date_debut': location.dateDebut,
        'date_fin': location.dateFin,
        'client_id': location.clientId,
        'prix_par_jour': location.prixParJour,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _locations = fetchLocations();
      });
    } else {
      throw Exception('Failed to create location');
    }
  }

  Future<void> updateLocation(Location location) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.14:3007/locations/${location.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'voiture_matricule': location.voitureMatricule,
        'date_debut': location.dateDebut,
        'date_fin': location.dateFin,
        'client_id': location.clientId,
        'prix_par_jour': location.prixParJour,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update location');
    }
    setState(() {
      _locations = fetchLocations();
    });
  }

  Future<void> deleteLocation(int id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.14:3007/locations/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete location');
    }
    setState(() {
      _locations = fetchLocations();
    });
  }

  Future<List<Voiture>> fetchVoitures() async {
    final response = await http.get(Uri.parse('http://192.168.1.14:3007/voitures'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Voiture.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load voitures');
    }
  }

  Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse('http://192.168.1.14:3007/clients'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locations CRUD'),
      ),
      body: FutureBuilder<List<Location>>(
        future: _locations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No locations available.'));
          }

          final locations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      location.voitureMatricule[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${location.voitureMatricule} (${formatDate(location.dateDebut)} - ${formatDate(location.dateFin)})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  subtitle: Text(
                    'Client ID: ${location.clientId}, Prix: ${location.prixParJour} dt/jour',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => UpdateLocationDialog(
                              location: location,
                              onUpdate: (updatedLocation) {
                                updateLocation(updatedLocation);
                              },
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteLocation(location.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddLocationDialog(
              onCreate: (location) {
                createLocation(location);
              },
            ),
          );
        },
      ),
    );
  }
}

class Location {
  final int id;
  final String voitureMatricule;
  final String dateDebut;
  final String dateFin;
  final int clientId;
  final double prixParJour;

  Location({
    required this.id,
    required this.voitureMatricule,
    required this.dateDebut,
    required this.dateFin,
    required this.clientId,
    required this.prixParJour,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      voitureMatricule: json['voiture_matricule'],
      dateDebut: json['date_debut'],
      dateFin: json['date_fin'],
      clientId: json['client_id'],
      prixParJour: (json['prix_par_jour'] as num).toDouble(),
    );
  }
}

class Voiture {
  final String matricule;
  final String marque;
  final String couleur;
  final double prixParJour;
  final String type;

  Voiture({
    required this.matricule,
    required this.marque,
    required this.couleur,
    required this.prixParJour,
    required this.type,
  });

  factory Voiture.fromJson(Map<String, dynamic> json) {
    return Voiture(
      matricule: json['matricule'],
      marque: json['marque'],
      couleur: json['couleur'],
      prixParJour: (json['prix_par_jour'] as num).toDouble(),
      type: json['type'],
    );
  }
}

class Client {
  final int id;
  final String nom;

  Client({
    required this.id,
    required this.nom,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
    );
  }
}

class AddLocationDialog extends StatefulWidget {
  final Function(Location) onCreate;

  AddLocationDialog({required this.onCreate});

  @override
  _AddLocationDialogState createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  late TextEditingController _voitureMatriculeController;
  late TextEditingController _dateDebutController;
  late TextEditingController _dateFinController;
  late TextEditingController _clientIdController;
  late TextEditingController _prixParJourController;

  @override
  void initState() {
    super.initState();
    _voitureMatriculeController = TextEditingController();
    _dateDebutController = TextEditingController();
    _dateFinController = TextEditingController();
    _clientIdController = TextEditingController();
    _prixParJourController = TextEditingController();
  }

  @override
  void dispose() {
    _voitureMatriculeController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _clientIdController.dispose();
    _prixParJourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter une nouvelle location'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _voitureMatriculeController,
              decoration: InputDecoration(labelText: 'Voiture Matricule'),
            ),
            TextField(
              controller: _dateDebutController,
              decoration: InputDecoration(labelText: 'Date Début'),
            ),
            TextField(
              controller: _dateFinController,
              decoration: InputDecoration(labelText: 'Date Fin'),
            ),
            TextField(
              controller: _clientIdController,
              decoration: InputDecoration(labelText: 'Client ID'),
            ),
            TextField(
              controller: _prixParJourController,
              decoration: InputDecoration(labelText: 'Prix par Jour'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Annuler'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Ajouter'),
          onPressed: () {
            final location = Location(
              id: 0,
              voitureMatricule: _voitureMatriculeController.text,
              dateDebut: _dateDebutController.text,
              dateFin: _dateFinController.text,
              clientId: int.parse(_clientIdController.text),
              prixParJour: double.parse(_prixParJourController.text),
            );
            widget.onCreate(location);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class UpdateLocationDialog extends StatefulWidget {
  final Location location;
  final Function(Location) onUpdate;

  UpdateLocationDialog({required this.location, required this.onUpdate});

  @override
  _UpdateLocationDialogState createState() => _UpdateLocationDialogState();
}

class _UpdateLocationDialogState extends State<UpdateLocationDialog> {
  late TextEditingController _voitureMatriculeController;
  late TextEditingController _dateDebutController;
  late TextEditingController _dateFinController;
  late TextEditingController _clientIdController;
  late TextEditingController _prixParJourController;

  @override
  void initState() {
    super.initState();
    _voitureMatriculeController = TextEditingController(text: widget.location.voitureMatricule);
    _dateDebutController = TextEditingController(text: widget.location.dateDebut);
    _dateFinController = TextEditingController(text: widget.location.dateFin);
    _clientIdController = TextEditingController(text: widget.location.clientId.toString());
    _prixParJourController = TextEditingController(text: widget.location.prixParJour.toString());
  }

  @override
  void dispose() {
    _voitureMatriculeController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _clientIdController.dispose();
    _prixParJourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier la location'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _voitureMatriculeController,
              decoration: InputDecoration(labelText: 'Voiture Matricule'),
            ),
            TextField(
              controller: _dateDebutController,
              decoration: InputDecoration(labelText: 'Date Début'),
            ),
            TextField(
              controller: _dateFinController,
              decoration: InputDecoration(labelText: 'Date Fin'),
            ),
            TextField(
              controller: _clientIdController,
              decoration: InputDecoration(labelText: 'Client ID'),
            ),
            TextField(
              controller: _prixParJourController,
              decoration: InputDecoration(labelText: 'Prix par Jour'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Annuler'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Modifier'),
          onPressed: () {
            final updatedLocation = Location(
              id: widget.location.id,
              voitureMatricule: _voitureMatriculeController.text,
              dateDebut: _dateDebutController.text,
              dateFin: _dateFinController.text,
              clientId: int.parse(_clientIdController.text),
              prixParJour: double.parse(_prixParJourController.text),
            );
            widget.onUpdate(updatedLocation);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
