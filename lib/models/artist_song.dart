import 'song.dart';

class ArtistSong {
  final int id;
  final String title;
  final String audioUrl;
  final int duration;
  final String artist;
  final String coverUrl;
  final int artistId; // 👈 THÊM TRƯỜNG NÀY
  final String avatarUrl;
  final String bio;
  final int views;

  ArtistSong({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.duration,
    required this.artist,
    required this.coverUrl,
    required this.artistId, // 👈 BẮT BUỘC
    required this.avatarUrl,
    required this.bio,
    required this.views,
  });

  factory ArtistSong.fromJson(Map<String, dynamic> json) {
    return ArtistSong(
      id: json['id'],
      title: json['title'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
      artist: json['artist'] ?? "", // API trả tên ca sĩ
      coverUrl: json['coverUrl'] ?? "",
      artistId: json['artistId'] ?? 0, // 👈 nếu API không trả thì mặc định 0
      avatarUrl: json['avatarUrl'] ?? 0,
      bio: json['bio'] ?? "",
      views: json['views'] ?? 0,
    );
  }
}

/// 🔄 Convert sang Song để dùng trong Player
extension ArtistSongExt on ArtistSong {
  Song toSong() => Song(
    id: id,
    title: title,
    artist: artist,
    artistId: artistId,
    audioUrl: audioUrl,
    coverUrl: coverUrl,
    duration: duration,
    views: views,           // nếu cần view phải gọi API tăng view
    isFavorite: false,  // sẽ cập nhật từ FavoriteProvider
  );
}
