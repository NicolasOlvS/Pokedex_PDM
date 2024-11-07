import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import '../services/database_helper.dart';
import '../services/pokemon_service.dart';

class EncontroDiarioPage extends StatefulWidget {
  const EncontroDiarioPage({Key? key}) : super(key: key);

  @override
  _EncontroDiarioPageState createState() => _EncontroDiarioPageState();
}

class _EncontroDiarioPageState extends State<EncontroDiarioPage> {
  Pokemon? _pokemonDoDia;
  late Timer _timer;
  Duration _tempoRestante = Duration(hours: 24);
  bool _pokemonCapturado = false;
  final int maxCapturas = 6;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final PokemonService _pokemonService = PokemonService();

  @override
  void initState() {
    super.initState();
    _carregarPokemonDoDia();
    _iniciarContador();
  }

  Future<void> _carregarPokemonDoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimoPokemonId = prefs.getInt('ultimoPokemonId');
    final ultimoEncontro = prefs.getInt('ultimoEncontro');
    final capturasHoje = prefs.getBool('pokemonCapturadoHoje') ?? false;

    final agora = DateTime.now();
    if (ultimoEncontro == null ||
        agora.difference(DateTime.fromMillisecondsSinceEpoch(ultimoEncontro)).inHours >= 24) {
      _pokemonDoDia = await _sortearPokemon();
      await prefs.setInt('ultimoPokemonId', _pokemonDoDia!.id);
      await prefs.setInt('ultimoEncontro', agora.millisecondsSinceEpoch);
      await prefs.setBool('pokemonCapturadoHoje', false);
    } else {
      _pokemonDoDia = await _carregarPokemonPorId(ultimoPokemonId!);
      setState(() {
        _tempoRestante = Duration(hours: 24) -
            agora.difference(DateTime.fromMillisecondsSinceEpoch(ultimoEncontro));
        _pokemonCapturado = capturasHoje;
      });
    }
  }

  Future<Pokemon> _sortearPokemon() async {
    final randomId = Random().nextInt(800) + 1;
    final pokemon = await _pokemonService.fetchPokemonById(randomId);
    await _dbHelper.insertPokemon(pokemon);
    return pokemon;
  }

  Future<Pokemon> _carregarPokemonPorId(int id) async {
    return await _pokemonService.fetchPokemonById(id);
  }

  void _iniciarContador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_tempoRestante.inSeconds > 0) {
          _tempoRestante -= const Duration(seconds: 1);
        } else {
          _carregarPokemonDoDia();
        }
      });
    });
  }

  Future<void> _capturarPokemon() async {
    if (_pokemonCapturado) return;

    final prefs = await SharedPreferences.getInstance();
    final meusPokemons = prefs.getStringList('meusPokemons') ?? [];

    if (meusPokemons.length >= maxCapturas) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Você já possui 6 Pokémon!")));
      return;
    }

    meusPokemons.add(_pokemonDoDia!.id.toString());
    await prefs.setStringList('meusPokemons', meusPokemons);
    await prefs.setBool('pokemonCapturadoHoje', true);

    setState(() {
      _pokemonCapturado = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pokémon capturado!")));
  }

  Future<void> _adiantarEncontro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ultimoEncontro'); 
    await _carregarPokemonDoDia(); 

    setState(() {
      _tempoRestante = Duration(hours: 24); 
      _pokemonCapturado = false;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encontro Diário'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/econtro.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: _pokemonDoDia == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pokémon do dia:',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Image.network(
                        'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${_pokemonDoDia!.id.toString().padLeft(3, '0')}.png',
                        width: 120,
                        height: 120,
                      ),
                      Text(
                        'Nome: ${_pokemonDoDia!.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tipo(s): ${_pokemonDoDia!.types.join(', ')}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tempo restante: ${_tempoRestante.inHours}:${(_tempoRestante.inMinutes % 60).toString().padLeft(2, '0')}:${(_tempoRestante.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _pokemonCapturado ? null : _capturarPokemon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Capturar Pokémon',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _adiantarEncontro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Adiantar Encontro (Trocar Pokémon)',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
