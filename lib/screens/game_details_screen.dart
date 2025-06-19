import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/game_data.dart';
import '../screens/add_game_screen.dart';

class GameDetailsScreen extends StatefulWidget {
  final GameData game;

  const GameDetailsScreen({super.key, required this.game});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  GameData get game => widget.game;
  bool _showEmailPassword = false;
  bool _showSonyPassword = false;
  late PageController _screenshotController;
  int _currentScreenshot = 0;

  @override
  void initState() {
    super.initState();
    _screenshotController = PageController();
  }

  @override
  void dispose() {
    _screenshotController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Widget _buildCredentialItem(String title, String value, IconData icon, {bool isPassword = false, bool showPassword = false, VoidCallback? onTogglePassword}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copyToClipboard(context, value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF00E5FF),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF00E5FF).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPassword ? (showPassword ? value : '••••••••') : value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPassword)
                IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF00E5FF),
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  color: Color(0xFF00E5FF),
                  size: 20,
                ),
                onPressed: () => _copyToClipboard(context, value),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              actions: [

                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF00E5FF),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddGameScreen(gameToEdit: game),
                      ),
                    );
                  },
                ),
              ],
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  game.gameName,
                  style: const TextStyle(color: Colors.white),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'game_logo_${game.gameName}',
                      child: CachedNetworkImage(
                        imageUrl: game.logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Theme.of(context).colorScheme.background,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (game.rating > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00E5FF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(5, (index) => Icon(
                              index < (game.rating / 2).round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFF00E5FF),
                              size: 28,
                            )),
                            const SizedBox(width: 12),
                            Text(
                              game.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (game.genres.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Genres',
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: game.genres.map((genre) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF00E5FF)),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    if (game.screenshots.isNotEmpty) ...[
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _screenshotController,
                              itemCount: game.screenshots.length,
                              onPageChanged: (index) => setState(() => _currentScreenshot = index),
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CachedNetworkImage(
                                    imageUrl: game.screenshots[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF00E5FF),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            if (game.screenshots.length > 1)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      game.screenshots.length,
                                      (index) => Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentScreenshot == index
                                              ? const Color(0xFF00E5FF)
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: const Color(0xFF00E5FF),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Game Credentials',
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCredentialItem(
                            'Username',
                            game.username,
                            Icons.person,
                          ),
                          Divider(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                          _buildCredentialItem(
                            'Email',
                            game.email,
                            Icons.email,
                          ),
                          Divider(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                          _buildCredentialItem(
                            'Email Password',
                            game.emailPassword,
                            Icons.lock,
                            isPassword: true,
                            showPassword: _showEmailPassword,
                            onTogglePassword: () => setState(() => _showEmailPassword = !_showEmailPassword),
                          ),
                          Divider(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                          _buildCredentialItem(
                            'Sony Password',
                            game.sonyPassword,
                            Icons.gamepad,
                            isPassword: true,
                            showPassword: _showSonyPassword,
                            onTogglePassword: () => setState(() => _showSonyPassword = !_showSonyPassword),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
