class RadioDeezer {
  final int id;
  final String title;
  final String picture_small;

  RadioDeezer({this.id, this.title, this.picture_small});

  factory RadioDeezer.fromJson(Map<String, dynamic> json) {
    return RadioDeezer(
        id: json['id'],
        title: cleanTitle(json['title']),
        picture_small: json['picture_small']
    );
  }

  bool operator ==(o) => o is RadioDeezer && id == o.id;

  int get hashCode => id;
}

String cleanTitle(String title) {
  int index = title.indexOf('DEFINING MUSIC 19');
  if (index > 0)
    return 'Années ' + title.substring(index + 17);

  index = title.indexOf('DEFINING MUSIC 20');
  if (index > 0)
    return 'Années ' + title.substring(index + 15);
  return title;
}