class Song {
  final int id;
  final String title;
  final String artist;
  final int artistId;
  final String audioUrl;
  final String coverUrl;
  final int duration;
  int views;
  bool isFavorite;
  // final String avatarUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.audioUrl,
    required this.coverUrl,
    required this.duration,
    required this.views,
    this.isFavorite = false,
    // required this.avatarUrl,

  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'] ?? '',
      artist: _parseArtist(json['artist'] ?? json['artistName'] ?? ''),
      artistId: json['artistId'] ?? 0,
      audioUrl: json['audioUrl'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      duration: json['duration'] ?? 0,
      views: json['views'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      // avatarUrl: json['avatarUrl'] ?? 0,
    );
  }

  /// 🔐 AN TOÀN: xử lý mọi kiểu artist
  static String _parseArtist(dynamic artist) {
    if (artist == null) return '';
    if (artist is String) return artist;
    if (artist is Map) return artist['name'] ?? '';
    return '';
  }
}
