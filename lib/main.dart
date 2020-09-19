import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cisko Music',
      theme: ThemeData(

        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Cisko Music'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Musique> maListeDeMusiques = [
    new Musique('Theme Swift', 'Codabee', 'assets/un.jpg', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Musique('Theme Flutter', 'Codabee', 'assets/deux.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
    new Musique('Epidode 238', 'Lescastcodeurs', 'assets/deux.jpg', 'https://hwcdn.libsyn.com/p/7/7/a/77a8cda12d2f81c9/LesCastCodeurs-Episode-238.mp3?c_id=83575334&cs_id=83575334&expiration=1600529315&hwt=f7a39b0d07710463f0208f5905f3b50f'),

  ];

  Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSub;
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            textAvecStyle(maMusiqueActuelle.titre, 1.5),
            textAvecStyle(maMusiqueActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton(statut == PlayerState.playing ? Icons.pause : Icons.play_arrow, 45.0, (statut == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textAvecStyle(fromDuration(position), 0.8),
                textAvecStyle(fromDuration(duree), 0.8)
              ],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: duree.inSeconds.toDouble(),
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d){
                  setState(() {
                    Duration duration = Duration(seconds: d.toInt());
                    position = duration;
                  });
                },
              onChangeEnd: (double value){
                changerPosition(value);
              },
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey[800],
    );
  }

  Text textAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic
      ),
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action){
    return new IconButton(
        icon: new Icon(icone),
        iconSize: taille,
        color: Colors.white,
        onPressed: () {
          switch(action){
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.forward:
              forward();
              break;
            case ActionMusic.rewind:
              rewind();
              break;  
          }
        }
    );
  }

  void configurationAudioPlayer(){
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
            (pos) => setState(() => position = pos)
    );
    stateSub = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == AudioPlayerState.PLAYING){
        duree = audioPlayer.duration;
      } else if(state == AudioPlayerState.STOPPED){
        statut = PlayerState.stopped;
      }
    },
      onError: (message) {
        setState(() {
          statut = PlayerState.stopped;
        });
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      }
    );
  }

  Future play() async{
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause () async{
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

   void forward() {
    if(index == maListeDeMusiques.length - 1){
      index = 0;
    }else{
      index++;
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    //configurationAudioPlayer();
    play();
  }

  void rewind() {
    if(position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    }else{
      if(index == 0){
        index = maListeDeMusiques.length - 1;
      }else{
        index--;
      }
    }

    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    //configurationAudioPlayer();
    play();
  }


  String fromDuration(Duration duree){
    print(duree);
    return duree.toString().split('.').first;
  }

  void changerPosition(double pos){
    setState(() {
      position = Duration(seconds: pos.toInt());
      audioPlayer.seek(pos);
    });
  }
}

enum ActionMusic{
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  paused,
  stopped

}