class UserFavorite {
  final int userId;
  final int songId;

  UserFavorite({
    required this.userId,
    required this.songId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'songId': songId,
    };
  }
}
