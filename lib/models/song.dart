// models/song.dart - Song data model
class Song {
  final String title;
  final String artist;
  final String url;
  final String imageUrl;

  const Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.imageUrl,
  });
  
  // Factory constructor to create a Song from JSON
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'] ?? 'assets/images/logo.png',
    );
  }
}