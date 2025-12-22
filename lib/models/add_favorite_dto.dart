class AddFavoriteDto {
  final int userId;
  final int songId;

  AddFavoriteDto({
    required this.userId,
    required this.songId,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "songId": songId,
  };
}
