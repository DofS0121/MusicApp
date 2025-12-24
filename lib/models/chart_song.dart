class ChartSong {
  final int songId;
  final String title;
  final String artist;
  final int artistId;
  final String coverUrl;
  final String audioUrl;
  final int duration;
  final int rank;
  final int? prevRank;
  final int viewCount;
  bool isFavorite;

  ChartSong({
    required this.songId,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.coverUrl,
    required this.audioUrl,
    required this.duration,
    required this.rank,
    this.prevRank,
    required this.viewCount,
    this.isFavorite = false,
  });

  factory ChartSong.fromJson(Map<String, dynamic> json) {
    return ChartSong(
      songId: json['songId'],
      title: json['title'],
      artist: json['artist'],
      artistId: json['artistId'],
      coverUrl: json['coverUrl'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
      rank: json['rank'],
      prevRank: json['prevRank'],
      viewCount: json['viewCount'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
