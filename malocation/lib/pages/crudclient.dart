import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Modèle Client avec le champ 'password'
class Client {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String password;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
    };
  }
}

// Service API
class ClientService {
  static const String baseUrl = 'http://192.168.1.14:3007';

  static Future<List<Client>> getAllClients() async {
    final response = await http.get(Uri.parse('$baseUrl/clientss'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Client> clients = body.map((dynamic item) => Client.fromJson(item)).toList();
      return clients;
    } else {
      throw Exception('Failed to load clients');
    }
  }

  static Future<void> createClient(Client client) async {
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add client');
    }
  }

  static Future<void> updateClient(Client client) async {
    final response = await http.put(
      Uri.parse('$baseUrl/clients/${client.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update client');
    }
  }

  static Future<void> deleteClient(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/clients/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete client');
    }
  }
}

// Interface Utilisateur (Page CRUD)
class CrudClientPage extends StatefulWidget {
  @override
  _CrudClientPageState createState() => _CrudClientPageState();
}

class _CrudClientPageState extends State<CrudClientPage> {
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clients = await ClientService.getAllClients();
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load clients')),
      );
    }
  }

  void _showClientForm({Client? client}) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String nom = client?.nom ?? '';
    String prenom = client?.prenom ?? '';
    String email = client?.email ?? '';
    String password = client?.password ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client == null ? 'Add Client' : 'Edit Client'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: nom,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => nom = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a nom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: prenom,
                  decoration: InputDecoration(
                    labelText: 'Prenom',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => prenom = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a prenom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => email = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSaved: (value) => password = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                try {
                  if (client == null) {
                    await ClientService.createClient(Client(id: 0, nom: nom, prenom: prenom, email: email, password: password));
                  } else {
                    await ClientService.updateClient(Client(id: client.id, nom: nom, prenom: prenom, email: email, password: password));
                  }
                  _fetchClients();
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save client')),
                  );
                }
              }
            },
            child: Text(client == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteClient(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ClientService.deleteClient(id);
                _fetchClients();
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete client')),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Clients CRUD'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _clients.length,
        itemBuilder: (context, index) {
          final client = _clients[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  client.nom[0].toUpperCase(), // Display the first letter of the client's name
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                '${client.nom} ${client.prenom}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(client.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showClientForm(client: client),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteClient(client.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () => _showClientForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
