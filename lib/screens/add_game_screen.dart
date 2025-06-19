import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../models/game_data.dart';
import '../providers/game_provider.dart';
import 'package:provider/provider.dart';

class AddGameScreen extends StatefulWidget {
  final GameData? gameToEdit;

  const AddGameScreen({super.key, this.gameToEdit});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  final _formKey = GlobalKey<FormState>();
  final _gameNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailPassController = TextEditingController();
  final _sonyPassController = TextEditingController();
  String? _selectedLogoUrl;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  ScrollController _scrollController = ScrollController();

  Future<void> _searchGames(String gameName) async {
    if (gameName.isEmpty) return;

    setState(() {
      _isSearching = true;
      _currentPage = 1;
      _hasMoreData = true;
      _searchResults.clear();
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.rawg.io/api/games?key=a98925744773401ba62aca7236a45b05&search=${Uri.encodeComponent(gameName)}&page_size=$_pageSize&page=$_currentPage'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = (data['results'] as List)
              .map((game) => {
                    'name': game['name'] as String,
                    'background_image': game['background_image'] as String? ?? '',
                    'rating': game['rating'],
                    'genres': game['genres'] ?? [],
                    'short_screenshots': game['short_screenshots'] ?? [],
                  })
              .toList();
          _hasMoreData = data['next'] != null;
        });

        _showLogoSelectionDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching games: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _loadMoreGames(String gameName) async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.rawg.io/api/games?key=a98925744773401ba62aca7236a45b05&search=${Uri.encodeComponent(gameName)}&page_size=$_pageSize&page=${_currentPage + 1}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults.addAll((data['results'] as List)
              .map((game) => {
                    'name': game['name'] as String,
                    'background_image': game['background_image'] as String? ?? '',
                    'rating': game['rating'],
                    'genres': game['genres'] ?? [],
                    'short_screenshots': game['short_screenshots'] ?? [],
                  })
              .toList());
          _currentPage++;
          _hasMoreData = data['next'] != null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more games: $e')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _showLogoSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Game Logo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length + (_hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _searchResults.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _isLoadingMore
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF00E5FF),
                                )
                              : const SizedBox(),
                        ),
                      );
                    }

                    final game = _searchResults[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedLogoUrl = game['background_image'];
                              _gameNameController.text = game['name']!;
                            });
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF00E5FF),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: game['background_image']!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: game['background_image']!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF00E5FF),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                const Icon(
                                              Icons.games,
                                              color: Color(0xFF00E5FF),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.games,
                                            color: Color(0xFF00E5FF),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    game['name']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveGame() {
    if (_formKey.currentState!.validate() && _selectedLogoUrl != null) {
      final selectedGame = _searchResults.firstWhere((game) => game['background_image'] == _selectedLogoUrl);
      print('Selected Game Data:');
      print('Rating: ${selectedGame['rating']}');
      print('Genres: ${selectedGame['genres']}');
      final genres = (selectedGame['genres'] as List<dynamic>?)?.map((g) {
        final genre = g as Map<String, dynamic>;
        return genre['name'] as String;
      }).toList() ?? <String>[];

      final screenshots = (selectedGame['short_screenshots'] as List<dynamic>?)?.map((s) {
        final screenshot = s as Map<String, dynamic>;
        return screenshot['image'] as String;
      }).toList() ?? <String>[];

      final rating = selectedGame['rating'] != null
          ? (selectedGame['rating'] as num).toDouble()
          : 0.0;

      final game = GameData(
        gameName: selectedGame['name'] ?? 'Unknown Game',
        username: _usernameController.text,
        email: _emailController.text,
        emailPassword: _emailPassController.text,
        sonyPassword: _sonyPassController.text,
        logoUrl: selectedGame['background_image'] ?? '',
        rating: rating,
        genres: genres,
        screenshots: screenshots,

      );
      context.read<GameProvider>().addGame(game);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameToEdit != null ? 'Edit Game' : 'Add Game'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_selectedLogoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_selectedLogoUrl!),
                  ),
                ),
              TextFormField(
                controller: _gameNameController,
                decoration: InputDecoration(
                  labelText: 'Game Name',
                  suffixIcon: IconButton(
                    icon: _isSearching
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.search),
                    onPressed: _isSearching
                        ? null
                        : () => _searchGames(_gameNameController.text),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter game name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailPassController,
                decoration: const InputDecoration(labelText: 'Email Password'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter email password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sonyPassController,
                decoration: const InputDecoration(labelText: 'Sony Password'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter Sony password' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGame,
                child: const Text('Save Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initialize fields if editing existing game
    if (widget.gameToEdit != null) {
      _gameNameController.text = widget.gameToEdit!.gameName;
      _usernameController.text = widget.gameToEdit!.username;
      _emailController.text = widget.gameToEdit!.email;
      _emailPassController.text = widget.gameToEdit!.emailPassword;
      _sonyPassController.text = widget.gameToEdit!.sonyPassword;
      _selectedLogoUrl = widget.gameToEdit!.logoUrl;
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _emailPassController.dispose();
    _sonyPassController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreGames(_gameNameController.text);
      }
    }
  }
}
