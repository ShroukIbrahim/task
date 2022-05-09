
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'demoActive.dart';


//const String voiceUrl ='https://firebasestorage.googleapis.com/v0/b/vision-537ab.appspot.com/o/profileImages%2Fa42a9ea7-72d5-417c-8866-6324a679b8ad?alt=media&token=8ba7ea02-250f-4382-b789-185027995bdd';
    //'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3';

final String albumArtPath =
    'https://file-examples-com.github.io/uploads/2017/10/file_example_PNG_500kB.png';

class RemotePlayer extends StatelessWidget {
final String voiceUrl ;

  const RemotePlayer({Key? key, required this.voiceUrl}) : super(key: key);//='https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3';

@override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  Container(height: 50,width: size.width*.8,
        child: SoundPlayerUI.fromLoader(
          _createRemoteTrack,
          showTitle: true,
          audioFocus: AudioFocus.requestFocusAndDuckOthers,
        ),
      );
  }
  Future<Track> _createRemoteTrack(BuildContext context) async {
    var track = Track();
    // validate codec for example file
    if (1==2&&ActiveCodec().codec != Codec.mp3) {
      var error = SnackBar(
          backgroundColor: Colors.red,
          content: Text('You must set the Codec to MP3 to '
              'play the "Remote Example File"'));
      ScaffoldMessenger.of(context).showSnackBar(error);
    } else {
      // We have to play an example audio file loaded via a URL
      track = Track(trackPath: voiceUrl, codec: ActiveCodec().codec!);

     // track.trackTitle = 'Remote mpeg playback.';
     // track.trackAuthor = 'By flutter_sound';
      track.albumArtUrl = albumArtPath;

      if (kIsWeb) {
        track.albumArtAsset = null;
      } else if (Platform.isIOS) {
        track.albumArtAsset = 'AppIcon';
      } else if (Platform.isAndroid) {
        track.albumArtAsset = 'AppIcon.png';
      }
    }

    return track;
  }
}
