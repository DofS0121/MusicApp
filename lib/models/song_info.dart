class SongInfo {
  final int id;
  final String title;
  final String artist;
  final String coverUrl;
  final DateTime? releaseDate;
  final List<String> categories;

  SongInfo({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    this.releaseDate,
    this.categories = const [],
  });

  factory SongInfo.fromJson(Map<String, dynamic> json) {
    return SongInfo(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      coverUrl: json['coverUrl'],
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : null,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
    );
  }
}
