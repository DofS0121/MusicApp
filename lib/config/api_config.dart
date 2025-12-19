class ApiConfig {
  // ================= SERVER =================
  static const String host = "10.0.2.2";
  static const String port = "5000";

  static const String serverUrl = "http://$host:$port";
  static const String baseUrl = "$serverUrl/api";

  // ================= AUTH =================
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";

  static const String uploadAvatar =
      "$baseUrl/auth/upload-avatar";

  static const String userAvatarBaseUrl =
      "$serverUrl/uploads/avatars";

  // ================= ARTISTS =================
  static const String artists = "$baseUrl/artists";

  static String artistDetail(int id) =>
      "$baseUrl/artists/$id";

  static String songsByArtist(int artistId) =>
      "$baseUrl/artists/$artistId/songs";

  static const String artistAvatarBaseUrl =
      "$serverUrl/avatar_artist";

  // ================= SONGS =================
  static const String songs = "$baseUrl/songs";

  /// Swipe trái – thông tin bài hát
  static String songInfo(int id) =>
      "$baseUrl/songs/$id";

  /// Danh sách bài của ca sĩ
  static String songsByArtistV2(int artistId) =>
      "$baseUrl/songs/artist/$artistId";

  static const String uploadSong =
      "$baseUrl/songs/upload";

  static String increaseView(int songId) =>
      "$baseUrl/songs/$songId/view";

  static String searchSongs(String keyword) =>
      "$baseUrl/songs/search?q=$keyword";

  // ================= CATEGORIES =================
  static const String categories =
      "$baseUrl/categories";

  static String deleteCategory(int id) =>
      "$baseUrl/categories/$id";

  // ================= SONG - CATEGORIES =================
  static String categoriesBySong(int songId) =>
      "$baseUrl/song-categories/song/$songId";

  static const String addSongCategory =
      "$baseUrl/song-categories";

  static const String removeSongCategory =
      "$baseUrl/song-categories";

  // ================= LYRICS =================
  static String lyricsBySong(int songId) =>
      "$baseUrl/lyrics/song/$songId";
}
