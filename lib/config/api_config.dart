class ApiConfig {
  // ================= SERVER =================
  static const String host = "10.0.2.2";
  static const String port = "5000";

  static const String serverUrl = "http://$host:$port";
  static const String baseUrl = "$serverUrl/api";

  // ================= AUTH =================
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";

  // upload avatar user
  static const String uploadAvatar =
      "$baseUrl/auth/upload-avatar";

  // base url để load avatar user
  static const String userAvatarBaseUrl =
      "$serverUrl/uploads/avatars";

  // ================= ARTISTS =================
  static const String artists = "$baseUrl/artists";

  // GET artist by id
  static String artistDetail(int id) =>
      "$baseUrl/artists/$id";

  // POST create artist
  static const String createArtist =
      "$baseUrl/artists";

  // PUT update artist
  static String updateArtist(int id) =>
      "$baseUrl/artists/$id";

  // GET songs by artist
  static String songsByArtist(int artistId) =>
      "$baseUrl/artists/$artistId/songs";

  // base url avatar artist
  static const String artistAvatarBaseUrl =
      "$serverUrl/avatar_artist";

  // ================= SONGS =================
  static const String songs = "$baseUrl/songs";

  static String songInfo(int id) =>
      "$baseUrl/songs/$id";

  static String songDetail(int id) =>
      "$baseUrl/songs/$id";

  static String songsByArtistV2(int artistId) =>
      "$baseUrl/songs/artist/$artistId";

  static const String uploadSong =
      "$baseUrl/songs/upload";

  // 🔥 Tăng lượt nghe (POST)
  static String increaseView(int songId) =>
      "$baseUrl/songs/$songId/view";

  // 🔍 Search bài hát / nghệ sĩ
  // GET: /api/songs/search?q=abc
  static String searchSongs(String keyword) =>
      "$baseUrl/songs/search?q=$keyword";

  // ================= FAVORITES =================
  static const String addFavorite =
      "$baseUrl/favorites";

  static String getFavoritesByUser(int userId) =>
      "$baseUrl/favorites/$userId";

  static const String removeFavorite = "$baseUrl/favorites";

  // ================= LYRICS =================
  static String lyricsBySong(int songId) =>
      "$baseUrl/lyrics/song/$songId";


  // ================= CHART =================
  static String getChart(String type) =>
      "$baseUrl/charts/$type";

}
