import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:malocation/pages/home.dart'; // Assurez-vous que le chemin est correct
import 'package:malocation/pages/historique.dart';
import 'package:malocation/pages/recherche.dart';
import 'package:malocation/pages/profile.dart';
import 'package:malocation/pages/crudclient.dart';
import 'package:malocation/pages/crudlocation.dart';
import 'package:malocation/pages/crudvoiture.dart';

void main() {
  testWidgets('Client navigation test', (WidgetTester tester) async {
    // Construire un widget Scaffold avec un BottomNavigationBar pour tester
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IndexedStack(
            index: 0, // Teste la première page
            children: [
              Home(), // Remplacez par la page que vous voulez tester
              Recherche(),
              Historique(),
              Profile(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) {}, // Simulez les actions de navigation
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );

    // Vérifiez si la page Home est affichée
    expect(find.byType(Home), findsOneWidget);

    // Changez l'index pour tester d'autres pages
    // Testez si la page Recherche est affichée lorsque l'index est 1
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IndexedStack(
            index: 1, // Changez l'index pour tester la page Recherche
            children: [
              Home(),
              Recherche(),
              Historique(),
              Profile(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) {},
            currentIndex: 1,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );

    // Vérifiez si la page Recherche est affichée
    expect(find.byType(Recherche), findsOneWidget);
  });
}
