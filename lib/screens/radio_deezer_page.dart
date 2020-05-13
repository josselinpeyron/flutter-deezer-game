import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:blindtest/models/artist.dart';
import 'package:blindtest/models/radio_deezer.dart';
import 'package:blindtest/models/track.dart';
import 'package:blindtest/services/radio_service.dart';
import "package:dart_random_choice/dart_random_choice.dart";
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const TITLE_STYLE =
    TextStyle(height: 3, fontSize: 25, fontWeight: FontWeight.bold);
const MEDIUM_STYLE =
    TextStyle(height: 2, fontSize: 15, fontWeight: FontWeight.bold);
const BIG_STYLE =
    TextStyle(height: 2, fontSize: 20, fontWeight: FontWeight.bold);
const BIG_STYLE_SUCCESS = TextStyle(
    height: 2, fontSize: 25, fontWeight: FontWeight.bold, color: Colors.green);
const BIG_STYLE_FAIL = TextStyle(
    height: 2, fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red);
const POINT_STYLE = TextStyle(
    height: 2,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey);

class RadioDeezerPage extends StatefulWidget {
  final RadioDeezer radio;

  const RadioDeezerPage({Key key, this.title, this.radio}) : super(key: key);

  final String title;

  @override
  createState() => new RadioDeezerPageState(radio);
}

class RadioDeezerPageState extends State<RadioDeezerPage> {
  final RadioDeezer radio;
  List<Artist> artists;
  Set<Track> usedTracks = new Set();
  Artist artistToFind;
  int nbPoint = 0;
  int nbVus = 0;
  int nbStreak = 0;
  int nbStreakAll = 0;

  Artist selectedArtist;

  Track currentTrack;

  List<Track> tracks;

  RadioDeezerPageState(this.radio);

  AudioPlayer audioPlayer;
  var isLoading = false;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    AudioPlayer.logEnabled = false;
    getRadioDeezerTracks(radio).then((tracks) {
      setState(() {
        this.tracks = tracks;
        guessNewTrack();
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    usedTracks = new Set();
    super.dispose();
  }

  onTapArtist(Artist artist) {
    if (isLoading) return;
    nbVus++;
    var success = artist.id == artistToFind.id;
    if (success) {
      nbPoint++;
      nbStreak++;
    } else {
      nbStreak = 0;
    }

    nbStreakAll = max(nbStreakAll, nbStreak);

    this.selectedArtist = artist;
    showDialogAfterChoice(success, currentTrack);
    Future.delayed(const Duration(milliseconds: 3000), () {
      setState(() {
        guessNewTrack();
      });
    });
  }

  Future<List<Artist>> guessNewTrack() {
    if (tracks == null) return null;

    isLoading = true;

    artists = new List();
    artistToFind = null;
    Track randomTrack;
    while (randomTrack == null || usedTracks.contains(randomTrack)) {
      if (usedTracks.length >= tracks.length) {
        showDialogFinishedRadioDeezer();
        break;
      }
      randomTrack = randomChoice(tracks);
      if (randomTrack.preview == null) {
        usedTracks.add(randomTrack);
      }
    }
    usedTracks.add(randomTrack);
    artistToFind = randomTrack.artist;
    artists = buildArtistsChoiceList(tracks, artistToFind);
    audioPlayer.stop();
    return audioPlayer.play(randomTrack.preview).then((result) {
      if (result == 1) {
        isLoading = false;
        this.selectedArtist = null;
        this.currentTrack = randomTrack;
        return artists;
      } else
        return guessNewTrack();
    });
  }

  List<Artist> buildArtistsChoiceList(List<Track> tracks, Artist artistToFind) {
    var results = new List<Artist>();
    results.add(artistToFind);
    while (results.length < 3) {
      var otherTrack = randomChoice(tracks);
      if (!results.contains(otherTrack.artist)) results.add(otherTrack.artist);
    }
    results.shuffle();
    return results;
  }

  void showDialogFinishedRadioDeezer() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("C'est fini !"),
              content: new Text("Essayer un nouveau thème"),
              actions: [
                RaisedButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  void showDialogAfterChoice(bool success, Track track) {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 10 ), () {
            Navigator.of(context).pop(true);
          });
          return new AlertDialog(
            title: new Text(success ? getRandomSuccessMessage() : getRandomFailMessage(), style: success ? BIG_STYLE_SUCCESS : BIG_STYLE),
            //backgroundColor: success ? Colors.blueGrey : Colors.red,
            content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Container(
                      width: 200.00,
                      height: 200.00,
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: NetworkImage(track.album.cover_medium),
                          fit: BoxFit.fitHeight,
                        ),
                      )),
                  Text(track.title, style: MEDIUM_STYLE),
                  Text('par'),
                  Text(track.artist.name, style: BIG_STYLE),
                  Tab(
                    icon: Container(
                      child: Image(
                        image: AssetImage(
                          'assets/images/deezer.png',
                        ),
                      ),
                      height: 100,
                      width: 100,
                    ),
                  )
                ]),
            actions: [
              RaisedButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Artist>>(
        future: guessNewTrack(),
        builder: (BuildContext context, AsyncSnapshot<List<Artist>> snapshot) {
          var artists = snapshot.data;
          if (artists == null || artists.length == 0) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Thème : " + radio.title),
                ),
                body: Container(
                    alignment: Alignment.center,
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Chargement du thème..."),
                      Text(""),
                      Text('Powered by'),
                      Tab(
                        icon: Container(
                          child: Image(
                            image: AssetImage(
                              'assets/images/deezer.png',
                            ),
                          ),
                          height: 100,
                          width: 100,
                        ),
                      )
                    ]
                )
              )
            );
          }
          return Scaffold(
              appBar: AppBar(
                title: Text("Radio : " + radio.title),
              ),
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getMainImage(),
                    new Text(radio.title, style: MEDIUM_STYLE),
                    new Text(
                        nbPoint.toString() +
                            ' points sur ' +
                            nbVus.toString() +
                            ' - Streak : ' +
                            nbStreakAll.toString(),
                        style: POINT_STYLE),
                    Column(children: buildArtistRows(artists))
                  ]));
        });
  }

  Container getMainImage() {
    NetworkImage image = NetworkImage(radio.picture_small);

    return new Container(
        width: 100.00,
        height: 100.00,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: image,
            fit: BoxFit.fitHeight,
          ),
        ));
  }

  List<ListTile> buildArtistRows(List<Artist> artists) {
    var artistRows = artists
        .map((artist) => ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(artist.picture_small),
                radius: 30,
              ),
              title: Text(artist.name, style: getArtistRowStyle(artist)),
              onTap: () => onTapArtist(artist),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            ))
        .toList();
    return artistRows;
  }

  getArtistRowStyle(Artist artist) {
    if (this.selectedArtist == null ||
        artistToFind == null ||
        artist != selectedArtist) return BIG_STYLE;
    if (artistToFind == artist)
      return BIG_STYLE_SUCCESS;
    else
      return BIG_STYLE_FAIL;
  }
}

String getRandomSuccessMessage() {
  return randomChoice(
      [ 'Super Jean-Louis !',
        'SUPER !!! Ça c\'est mon poulain !',
        'Bien joué Marielle !',
        'WOW !!! AMAZING !!!',
        'JUST UNBELIEVABLE !',
        'AMAZING !',
        'TU M’IMPRESSIONNES !'
      ]);

}

String getRandomFailMessage() {
  return randomChoice(
  [ 'Peut mieux faire…',
    'Mention: Pas bien…',
    'Nan mais là tu déconnes…',
    'Allez, ressaisis toi !',
    'Nan mais franchement, je te reconnais plus là…',
    'Tu me déçois…',
    'Peut mieux faire…',
    'Mais il est où mon guerrier là?…',
    'Tu te ficherais pas un peu de moi par hasard ?!'
  ]);
}
