import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/pokemon.dart';

class DetalhesMeusPokemonsPage extends StatelessWidget {
  final Pokemon pokemon;

  const DetalhesMeusPokemonsPage({Key? key, required this.pokemon}) : super(key: key);

  Future<void> _soltarPokemon(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final meusPokemons = prefs.getStringList('meusPokemons') ?? [];

    meusPokemons.remove(pokemon.id.toString());
    await prefs.setStringList('meusPokemons', meusPokemons);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pokémon solto com sucesso!")),
    );

    Navigator.pop(context);
  }

  void _confirmarSoltarPokemon(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      headerAnimationLoop: false,
      title: 'Soltar Pokémon',
      desc: 'Tem certeza que deseja soltar ${pokemon.name}?',
      btnCancelOnPress: () {},
      btnOkOnPress: () => _soltarPokemon(context),
      btnOkText: 'Sim',
      btnCancelText: 'Cancelar',
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pokemon.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/${pokemon.id.toString().padLeft(3, '0')}.png',
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'ID: ${pokemon.id}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blueGrey),
              ),
            ),
            Center(
              child: Text(
                'Nome: ${pokemon.name}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
            Center(
              child: Text(
                'Tipos: ${pokemon.types.join(', ')}',
                style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Atributos Base:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            ...pokemon.baseStats.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                )),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _confirmarSoltarPokemon(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Soltar Pokémon'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 211, 83, 67),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
