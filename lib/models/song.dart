class Song {
  final int id;
  final String title;
  final String artist;
  final int artistId;
  final String audioUrl;
  final String coverUrl;
  final int duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.audioUrl,
    required this.coverUrl,
    required this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      artistId: json['artistId'],
      audioUrl: json['audioUrl'],
      coverUrl: json['coverUrl'],
      duration: json['duration'],
    );
  }
}
