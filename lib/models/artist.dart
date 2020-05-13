class Artist {
  final int id;
  final String name;
  final String picture_small;

  Artist({this.id, this.name, this.picture_small});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
        id: json['id'],
        name: json['name'],
        picture_small: json['picture_small']
    );
  }

  bool operator ==(o) => o is Artist && id == o.id;

  int get hashCode => id;
}
