import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/pokedex_page.dart';
import 'screens/encontro_diario_page.dart'; 
import 'screens/meus_pokemons_page.dart';
import 'screens/segredo.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/pokedex': (context) => const PokedexPage(),
        '/dailyEncounter': (context) => const EncontroDiarioPage(),
        '/myPokemons': (context) => const MeusPokemonsPage(),
        '/segredo': (context) => const SegredoPage(),
      },
    );
  }
}
