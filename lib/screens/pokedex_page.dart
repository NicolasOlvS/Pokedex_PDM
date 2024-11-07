import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../screens/pokemon_detail_page.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  @override
  _PokedexPageState createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  final PokemonService _pokemonService = PokemonService();
  static const int pageSize = 20;

  final PagingController<int, Pokemon> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPokemons = await _pokemonService.fetchPokemonsPage(pageKey, pageSize);
      final isLastPage = newPokemons.length < pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newPokemons);
      } else {
        final nextPageKey = pageKey + newPokemons.length;
        _pagingController.appendPage(newPokemons, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<String> _getLocalImagePath(int pokemonId) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pokemon_images/${pokemonId.toString().padLeft(3, '0')}.png';
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: PagedListView<int, Pokemon>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Pokemon>(
          itemBuilder: (context, pokemon, index) {
            return FutureBuilder<String>(
              future: _getLocalImagePath(pokemon.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final localImagePath = snapshot.data;
                  return Card(
                    color: Colors.blue[100], 
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PokemonDetailPage(pokemon: pokemon),
                          ),
                        );
                      },
                      leading: Image.file(
                        File(localImagePath!),
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png',
                            width: 50,
                            height: 50,
                          );
                        },
                      ),
                      title: Text(pokemon.name),
                      subtitle: Text('Tipo: ${pokemon.types.join(', ')}'),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          },
          noItemsFoundIndicatorBuilder: (context) =>
              const Center(child: Text('Nenhum Pokémon encontrado')),
          firstPageProgressIndicatorBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
