import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon App'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.7, // Ajuste a opacidade conforme necessário
              child: Image.asset(
                'assets/fundo.jpeg', // Certifique-se de que a imagem está na pasta de assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  label: 'Pokédex',
                  onPressed: () => Navigator.pushNamed(context, '/pokedex'),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Encontro Diário',
                  onPressed: () => Navigator.pushNamed(context, '/dailyEncounter'),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Meus Pokémons',
                  onPressed: () => Navigator.pushNamed(context, '/myPokemons'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Opacity(
              opacity: 0.0, // Tornar o botão invisível
              child: IconButton(
                icon: const Icon(Icons.circle),
                onPressed: () => Navigator.pushNamed(context, '/segredo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({required this.label, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.black,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
