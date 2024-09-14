import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Historique extends StatefulWidget {
  @override
  _HistoriqueState createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  List<dynamic> locations = [];
  String? clientId;

  @override
  void initState() {
    super.initState();
    _fetchClientId().then((id) {
      if (id != null) {
        _fetchLocations(id);
      }
    });
  }

  Future<String?> _fetchClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _fetchLocations(String clientId) async {
    final response = await http.get(Uri.parse('http://192.168.1.14:3007/locations/client/$clientId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        locations = data;
      });
    } else {
      // Handle error
      print('Failed to load locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: locations.isEmpty
            ? Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Text(
              'Aucune transaction n\'a été affectée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.blueGrey, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Voiture: ${location['marque']} (${location['type']})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.color_lens, color: Colors.grey, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Couleur: ${location['couleur']}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.money, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Prix par jour: ${location['prix_par_jour']} DT',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Date de début: ${DateTime.parse(location['date_debut']).toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Date de fin: ${DateTime.parse(location['date_fin']).toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
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
