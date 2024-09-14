import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class Crudvoiture extends StatefulWidget {
  @override
  _CrudvoitureState createState() => _CrudvoitureState();
}

class _CrudvoitureState extends State<Crudvoiture> {
  List<Voiture> voitures = [];
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _marqueController = TextEditingController();
  final _couleurController = TextEditingController();
  final _typeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _prixParJourController = TextEditingController();
  bool _disponibilite = true;
  bool _isEditMode = false;
  String _currentMatricule = '';

  @override
  void initState() {
    super.initState();
    fetchVoitures();
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

  Future<void> addOrUpdateVoiture() async {
    if (_formKey.currentState?.validate() ?? false) {
      final voitureData = {
        'marque': _marqueController.text,
        'couleur': _couleurController.text,
        'type': _typeController.text,
        'disponibilite': _disponibilite ? 1 : 0,
        'image_url': _imageUrlController.text,
        'prix_par_jour': double.parse(_prixParJourController.text),
      };

      try {
        http.Response response;
        if (_isEditMode) {
          response = await http.put(
            Uri.parse('http://192.168.1.14:3007/voitures/$_currentMatricule'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(voitureData),
          );
        } else {
          response = await http.post(
            Uri.parse('192.168.1.14:3007/ajvoitures'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              ...voitureData,
              'matricule': _matriculeController.text,
            }),
          );
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          Fluttertoast.showToast(
            msg: 'Voiture ${_isEditMode ? 'mise à jour' : 'ajoutée'} avec succès',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          _formKey.currentState?.reset();
          setState(() {
            _isEditMode = false;
            _currentMatricule = '';
          });
          fetchVoitures();
        } else {
          throw Exception('Échec de l\'${_isEditMode ? 'mise à jour' : 'ajout'} de la voiture');
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Erreur lors de l\'${_isEditMode ? 'mise à jour' : 'ajout'} de la voiture',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<void> deleteVoiture(String matricule) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.14:3007/voitures/$matricule'),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Voiture supprimée avec succès',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        fetchVoitures();
      } else {
        throw Exception('Échec de la suppression de la voiture');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la suppression de la voiture',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _showVoitureDialog({Voiture? voiture}) {
    if (voiture != null) {
      _isEditMode = true;
      _currentMatricule = voiture.matricule;
      _matriculeController.text = voiture.matricule;
      _marqueController.text = voiture.marque;
      _couleurController.text = voiture.couleur;
      _typeController.text = voiture.type;
      _imageUrlController.text = voiture.imageUrl;
      _prixParJourController.text = voiture.prixParJour.toString();
      _disponibilite = voiture.disponibilite;
    } else {
      _isEditMode = false;
      _currentMatricule = '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${_isEditMode ? 'Modifier' : 'Ajouter'} une voiture 🚗'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isEditMode)
                    TextFormField(
                      controller: _matriculeController,
                      decoration: InputDecoration(labelText: 'Matricule'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le matricule';
                        }
                        return null;
                      },
                    ),
                  TextFormField(
                    controller: _marqueController,
                    decoration: InputDecoration(labelText: 'Marque'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la marque';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _couleurController,
                    decoration: InputDecoration(labelText: 'Couleur'),
                  ),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(labelText: 'Type'),
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: 'URL de l\'image'),
                  ),
                  TextFormField(
                    controller: _prixParJourController,
                    decoration: InputDecoration(labelText: 'Prix par jour'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Disponible ✅'),
                      Switch(
                        value: _disponibilite,
                        onChanged: (value) {
                          setState(() {
                            _disponibilite = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
              child: Text('${_isEditMode ? 'Modifier' : 'Ajouter'}'),
              onPressed: () {
                addOrUpdateVoiture();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voitures 🚘'),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: voitures.length,
          itemBuilder: (context, index) {
            final voiture = voitures[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 5,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: voiture.imageUrl.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    voiture.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
                    : ClipOval(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
                title: Text('${voiture.marque} 🚗', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Matricule: ${voiture.matricule}\nPrix par jour: ${voiture.prixParJour} DT',
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showVoitureDialog(voiture: voiture);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteVoiture(voiture.matricule);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVoitureDialog(),
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Crudvoiture(),
  ));
}
