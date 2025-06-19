import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/game_data.dart';

class GameProvider with ChangeNotifier {
  final List<GameData> _games = [];
  final _storage = const FlutterSecureStorage();
  static const String _storageKey = 'games';

  List<GameData> get games => List.unmodifiable(_games);

  GameProvider() {
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final gamesJson = await _storage.read(key: _storageKey);
      if (gamesJson != null) {
        final gamesList = json.decode(gamesJson) as List;
        _games.addAll(
          gamesList.map((game) => GameData.fromJson(game as Map<String, dynamic>)),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading games: $e');
    }
  }

  Future<void> _saveGames() async {
    try {
      final gamesJson = json.encode(
        _games.map((game) => game.toJson()).toList(),
      );
      await _storage.write(key: _storageKey, value: gamesJson);
    } catch (e) {
      debugPrint('Error saving games: $e');
    }
  }

  Future<void> updateGame(GameData oldGame, GameData newGame) async {
    final index = _games.indexWhere((g) => g.gameName == oldGame.gameName);
    if (index != -1) {
      _games[index] = newGame;
      await _saveGames();
      notifyListeners();
    }
  }

  Future<void> deleteGame(GameData game) async {
    _games.removeWhere((g) => g.gameName == game.gameName);
    await _saveGames();
    notifyListeners();
  }

  Future<void> addGame(GameData game) async {
    _games.add(game);
    await _saveGames();
    notifyListeners();
  }

  void removeGame(GameData game) {
    _games.remove(game);
    _saveGames();
    notifyListeners();
  }

  // void updateGame(GameData oldGame, GameData newGame) {
  //   final index = _games.indexOf(oldGame);
  //   if (index != -1) {
  //     _games[index] = newGame;
  //     _saveGames();
  //     notifyListeners();
  //   }
  // }
}
