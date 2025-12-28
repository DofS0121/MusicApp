class Playlist {
  final int id;
  final String name;
  final String? coverUrl;
  final int totalSongs;
  final int views;

  Playlist({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.totalSongs,
    required this.views,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      coverUrl: json['coverUrl'],
      totalSongs: json['totalSongs'],
      views: json['views'] ?? 0,
    );
  }
}
