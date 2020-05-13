import 'package:blindtest/models/radio_deezer.dart';
import 'package:blindtest/screens/radio_deezer_page.dart';
import 'package:blindtest/services/radio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RadioDeezerListPage extends StatefulWidget {
  @override
  createState() => _RadioDeezerListPageState();
}

class _RadioDeezerListPageState extends State {
  var radios = new List<RadioDeezer>();


  initState() {
    super.initState();
    getRadioDeezers().then((response) {
      setState(() {
        radios = response;
      });
    });
  }

  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Choisissez un thème"),
        ),
        body: ListView.builder(
          itemCount: radios.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(radios[index].picture_small),
              ),
              title: Text(radios[index].title),
              onTap: () => onTapRadioDeezer(radios[index]),
            );
          },
        ));
  }

  onTapRadioDeezer(RadioDeezer radio) {
    print('vous avez choisi ' + radio.title + '!!');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RadioDeezerPage(radio: radio)),
    );
  }
}