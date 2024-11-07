// pokemon.dart

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final Map<String, int> baseStats;
  final List<Move> moves;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.baseStats,
    required this.moves,
  });
  
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    try {
      return Pokemon(
        id: int.parse(json['id'].toString()), 
        name: json['name']['english'], 
        types: List<String>.from(
            json['type']), 
        baseStats: Map<String, int>.from(
          json['base']
              .map((key, value) => MapEntry(key, int.parse(value.toString()))),
        ),
        moves: [],
      );
    } catch (e) {
      print("Erro ao converter JSON para Pokemon: $e");
      throw Exception('Erro ao processar os dados do Pokémon');
    }
  }

  //String são ID, NOME e etc e Dynamic é os dados desses atributos, podendo ser de qualquer tipo como INT, STRING
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': {'english': name},
      'type': types,
      'base': baseStats,
    };
  }
}

class Move {
  final int id;
  final String ename;
  final String type;
  final int power;
  final int accuracy;
  final int pp;

  Move({
    required this.id,
    required this.ename,
    required this.type,
    required this.power,
    required this.accuracy,
    required this.pp,
  });

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      id: int.parse(json['id'].toString()),
      ename: json['ename'],
      type: json['type'],
      power: int.tryParse(json['power']?.toString() ?? '0') ?? 0,
      accuracy: int.tryParse(json['accuracy']?.toString() ?? '0') ?? 0,
      pp: int.tryParse(json['pp']?.toString() ?? '0') ?? 0,
    );
  }
}
