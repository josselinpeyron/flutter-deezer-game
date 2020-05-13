import 'dart:collection';
import 'dart:convert';

import 'package:blindtest/models/radio_deezer.dart';
import 'package:blindtest/models/track.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<http.Response> fetchRadioDeezers() async {
  return http.get('https://api.deezer.com/radio');
}

Future<http.Response> fetchRadioDeezerTracks(RadioDeezer radio) async {
  return http
      .get('https://api.deezer.com/radio/' + radio.id.toString() + '/tracks');
}

Future<List<RadioDeezer>> getRadioDeezers() {
  return fetchRadioDeezers().then((response) {
      var body = json.decode(response.body);
      List data = body['data'];
      Set<RadioDeezer> radioSet = new HashSet<RadioDeezer>();
      data.forEach((item) => radioSet.add(RadioDeezer.fromJson(item)));
      List<RadioDeezer> radios = radioSet.toList();
      radios.sort((a, b) => a.title.compareTo(b.title));
      return radios;
  });
}

Future<List<Track>> getRadioDeezerTracks(RadioDeezer radio) {
  return fetchRadioDeezerTracks(radio).then((response) {
    var body = json.decode(response.body);
    List data = body['data'];
    Set<Track> trackSet = new HashSet<Track>();
    data.forEach((item) => trackSet.add(Track.fromJson(item)));
    var tracks = trackSet.toList();
    tracks.shuffle();
    return tracks;
  });
}

