import 'album.dart';
import 'artist.dart';

class Track {
  final int id;
  final String title;
  final Artist artist;
  final Album album;
  final String preview;


  Track({this.id, this.title, this.artist, this.preview, this.album});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
        id: json['id'],
        title: json['title'],
        artist: Artist.fromJson(json['artist']),
        album:  Album.fromJson(json['album']),
        preview: json['preview']);
  }

  bool operator ==(o) => o is Track && id == o.id;

  int get hashCode => id;
}