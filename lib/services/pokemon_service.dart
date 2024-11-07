//database_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/pokemon.dart';
import 'database_helper.dart';

class PokemonService {
  static const String apiUrl ='https://2248-177-20-136-250.ngrok-free.app/pokemons'; 
  static const String movesApiUrl = 'https://2248-177-20-136-250.ngrok-free.app/moves';

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Função principal para buscar Pokémons paginados
  Future<List<Pokemon>> fetchPokemonsPage(int offset, int limit) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      print("Conectividade: $connectivityResult");

      if (connectivityResult != ConnectivityResult.none) {
        print("Conectado. Tentando acessar API: $apiUrl");
        final response = await http.get(Uri.parse(apiUrl));
        print("Status da resposta: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          List<Pokemon> allPokemons =
              data.map((json) => Pokemon.fromJson(json)).toList();
          List<Move> allMoves = await fetchMoves();

          for (var pokemon in allPokemons) {
            pokemon.moves.addAll(
              allMoves.where((move) => move.id == pokemon.id).toList(),
            );
          }

          List<Pokemon> pagePokemons =
              _getPaginatedPokemons(allPokemons, offset, limit);

          for (var pokemon in pagePokemons) {
            await _dbHelper.insertPokemon(pokemon);
            await savePokemonImage(pokemon.id);
          }

          print("Pokémons carregados e cache atualizado.");
          return pagePokemons;
        } else {
          print(
              'Erro ao acessar API. Status: ${response.statusCode}, Resposta: ${response.body}');
          throw Exception('Falha ao carregar os Pokémons');
        }
      } else {
        print("Sem conexão. Carregando dados do cache.");
        final cachedPokemons = await _dbHelper.getCachedPokemons();
        final cachedPokemonsWithImages =
            await _filterPokemonsWithImages(cachedPokemons);
        return _getPaginatedPokemons(cachedPokemonsWithImages, offset, limit);
      }
    } catch (e) {
      print("Erro durante o carregamento dos Pokémons: $e");
      rethrow; 
    }
  }

  Future<List<Move>> fetchMoves() async {
    try {
      final response = await http.get(Uri.parse(movesApiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Move.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar os moves');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API de moves');
    }
  }

  List<Pokemon> _getPaginatedPokemons(
      List<Pokemon> pokemons, int offset, int limit) {
    final endIndex = offset + limit;
    return pokemons.sublist(
      offset,
      endIndex > pokemons.length ? pokemons.length : endIndex,
    );
  }

  Future<void> savePokemonImage(int pokemonId) async {
    final url =
        'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemonId.toString().padLeft(3, '0')}.png';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/pokemon_images/${pokemonId.toString().padLeft(3, '0')}.png';

      final imageFile = File(imagePath);
      await imageFile.create(recursive: true);
      await imageFile.writeAsBytes(response.bodyBytes);
    }
  }

  Future<bool> _isImageCached(int pokemonId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath =
        '${directory.path}/pokemon_images/${pokemonId.toString().padLeft(3, '0')}.png';
    return File(imagePath).existsSync();
  }

  Future<List<Pokemon>> _filterPokemonsWithImages(
      List<Pokemon> pokemons) async {
    List<Pokemon> pokemonsWithImages = [];
    for (var pokemon in pokemons) {
      if (await _isImageCached(pokemon.id)) {
        pokemonsWithImages.add(pokemon);
      }
    }
    return pokemonsWithImages;
  }

  Future<Pokemon> fetchPokemonById(int id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pokemon = Pokemon.fromJson(data);
        pokemon.moves.addAll(await fetchMovesForPokemon(pokemon.id));
        return pokemon;
      } else {
        throw Exception('Erro ao carregar Pokémon');
      }
    } catch (e) {
      print("Erro ao carregar Pokémon: $e");
      rethrow;
    }
  }

  Future<List<Move>> fetchMovesForPokemon(int pokemonId) async {
    try {
      final response = await http.get(Uri.parse(movesApiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((moveJson) => Move.fromJson(moveJson))
            .where((move) => move.id == pokemonId)
            .toList();
      } else {
        throw Exception('Erro ao carregar movimentos');
      }
    } catch (e) {
      print("Erro ao carregar movimentos: $e");
      rethrow;
    }
  }

    Future<List<Pokemon>> fetchPokemonsFromCache(List<int> pokemonIds) async {
    final cachedPokemons = await _dbHelper.getCachedPokemons();
    return cachedPokemons.where((pokemon) => pokemonIds.contains(pokemon.id)).toList();
  }
}
