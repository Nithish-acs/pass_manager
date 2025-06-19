class GameData {
  final String logoUrl;
  final String gameName;
  final String username;
  final String email;
  final String emailPassword;
  final String sonyPassword;
  final double rating;
  final List<String> genres;
  final List<String> screenshots;


  GameData({
    required this.logoUrl,
    required this.gameName,
    required this.username,
    required this.email,
    required this.emailPassword,
    required this.sonyPassword,
    this.rating = 0.0,
    this.genres = const [],
    this.screenshots = const [],

  });

  Map<String, dynamic> toJson() => {
        'logoUrl': logoUrl,
        'gameName': gameName,
        'username': username,
        'email': email,
        'emailPassword': emailPassword,
        'sonyPassword': sonyPassword,
        'rating': rating,
        'genres': genres,
        'screenshots': screenshots,
    
      };

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
        logoUrl: json['logoUrl'],
        gameName: json['gameName'],
        username: json['username'],
        email: json['email'],
        emailPassword: json['emailPassword'],
        sonyPassword: json['sonyPassword'],
        rating: json['rating'] ?? 0.0,
        genres: List<String>.from(json['genres'] ?? []),
        screenshots: List<String>.from(json['screenshots'] ?? []),
    
      );
}
