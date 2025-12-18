class ArtistSong {
  final int id;
  final String title;
  final String audioUrl;
  final int duration;

  ArtistSong({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.duration,
  });

  factory ArtistSong.fromJson(Map<String, dynamic> json) {
    return ArtistSong(
      id: json['id'],
      title: json['title'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
    );
  }
}
