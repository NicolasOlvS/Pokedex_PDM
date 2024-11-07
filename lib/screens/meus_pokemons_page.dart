import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import 'detalhes_meus_pokemons.dart';

class MeusPokemonsPage extends StatefulWidget {
  const MeusPokemonsPage({Key? key}) : super(key: key);

  @override
  _MeusPokemonsPageState createState() => _MeusPokemonsPageState();
}

class _MeusPokemonsPageState extends State<MeusPokemonsPage> {
  List<Pokemon> _meusPokemons = [];
  final PokemonService _pokemonService = PokemonService();

  @override
  void initState() {
    super.initState();
    _carregarMeusPokemons();
  }

  Future<void> _carregarMeusPokemons() async {
    final prefs = await SharedPreferences.getInstance();
    final meusPokemonsIds = prefs.getStringList('meusPokemons') ?? [];

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      final pokemons = await _pokemonService.fetchPokemonsFromCache(
          meusPokemonsIds.map(int.parse).toList());
      setState(() {
        _meusPokemons = pokemons;
      });
    } else {
      final pokemons = await Future.wait(
        meusPokemonsIds.map((id) async {
          final pokemon = await _pokemonService.fetchPokemonById(int.parse(id));
          await _pokemonService.savePokemonImage(pokemon.id); // Salva a imagem no cache
          return pokemon;
        }),
      );
      setState(() {
        _meusPokemons = pokemons;
      });
    }
  }

  Future<String> _getLocalImagePath(int pokemonId) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pokemon_images/${pokemonId.toString().padLeft(3, '0')}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pokémons'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: _meusPokemons.length,
          itemBuilder: (context, index) {
            final pokemon = _meusPokemons[index];
            return FutureBuilder<String>(
              future: _getLocalImagePath(pokemon.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final imagePath = snapshot.data;
                  return Card(
                    color: Colors.blue[100],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imagePath != null && File(imagePath).existsSync()
                            ? Image.file(
                                File(imagePath),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                      ),
                      title: Text(
                        pokemon.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),  
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Tipo: ${pokemon.types.join(', ')}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesMeusPokemonsPage(pokemon: pokemon),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
