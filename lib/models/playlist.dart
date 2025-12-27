class Playlist {
  final int id;
  final String name;
  final String? coverUrl;
  final int totalSongs;

  Playlist({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.totalSongs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      coverUrl: json['coverUrl'],
      totalSongs: json['totalSongs'],
    );
  }
}
