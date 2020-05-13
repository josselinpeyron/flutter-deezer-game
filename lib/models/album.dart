import 'artist.dart';

class Album {
  final int id;
  final String title;
  final String cover_medium;


  Album({this.id, this.title, this.cover_medium});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        id: json['id'],
        title: json['title'],
        cover_medium: json['cover_medium']);
  }

  bool operator ==(o) => o is Album && id == o.id;

  int get hashCode => id;
}