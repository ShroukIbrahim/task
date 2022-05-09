// @dart=2.9
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../config/colorsFile.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';



/// Homepage
class BioDetailsScreen extends StatefulWidget {
  final GroceryUser consult;
  const BioDetailsScreen({Key key, this.consult}) : super(key: key);

  @override
  _BioDetailsScreenState createState() => _BioDetailsScreenState();
}

class _BioDetailsScreenState extends State<BioDetailsScreen> {
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;

  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  String theme="light";bool load=true;

  final List<String> _ids = [];


  @override
  void initState() {
    super.initState();
    if(widget.consult.link!=null&&widget.consult.link!=""){
      _ids.add(widget.consult.link);
      _controller = YoutubePlayerController(
        initialVideoId:widget.consult.link ,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(listener);
      _idController = TextEditingController();
      _seekToController = TextEditingController();
      _videoMetaData = const YoutubeMetaData();
      _playerState = PlayerState.unknown;
    }
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    if(widget.consult.link!=null&&widget.consult.link!="") {
      _controller.pause();
      _ids.clear();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if(widget.consult.link!=null&&widget.consult.link!="") {
      _controller.dispose();
      _idController.dispose();
      _seekToController.dispose();
      _ids.clear();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          (widget.consult.link!=null&&widget.consult.link!="")?Expanded(
            child: Text( _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ):SizedBox(),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller.load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
          //_showSnackBar('Next Video Started!');
        },
      ),
      builder: (context, player) => Scaffold(

        body: Stack(children: [
          Column(children: [
            Container(
                width: size.width,
                height: size.height * .25,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(00.0),
                    bottomRight: Radius.circular(00.0),
                  ),
                ),
                child: SafeArea(
                    child: Padding( padding: const EdgeInsets.only(
                        left: 5.0, right: 5.0, top: 0.0, bottom: 16.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.5),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: 38.0,
                                  height: 35.0,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: theme=="light"?Colors.white:Colors.black,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            getTranslated(context, "bio"),
                            textAlign:TextAlign.left,

                            style: GoogleFonts.cairo(
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                    ))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(physics:  AlwaysScrollableScrollPhysics(),children: [
                      SizedBox(
                        height: 5.0,
                      ),
                      Center(
                        child: Text(
                          widget.consult.name,
                          style: GoogleFonts.cairo(
                            color: AppColors.brown,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        widget.consult.bio,
                        style: GoogleFonts.cairo(
                          fontSize: 15.0,
                          color:theme=="light"?AppColors.black:AppColors.white,
                          //fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      (widget.consult.link!=null&&widget.consult.link!="")? ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),child: player):SizedBox(),
                      (widget.consult.link!=null&&widget.consult.link!="") ?SizedBox(height: 30.0,):SizedBox(),]))),

          ],),

          Positioned(
            right: 0.0,
            top: size.height * .18,
            left: 0,
            child: Center(
              child: Container(
                padding:const EdgeInsets.all(1),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor,width: 1),
                  shape: BoxShape.circle,
                  color:Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/trLogo.png',
                    placeholderScale: 0.5,
                    imageErrorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,color:Colors.black,
                      size: 50.0,
                    ),
                    image: widget.consult.photoUrl!=""?widget.consult.photoUrl:"",
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 250),
                    fadeInCurve: Curves.easeInOut,
                    fadeOutDuration: Duration(milliseconds: 150),
                    fadeOutCurve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}