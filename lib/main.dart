// @dart=2.9
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_product_bloc.dart';

import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/repositories/authentication_repository.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:grocery_store/screens/forceUpdateScreen.dart';
import 'package:grocery_store/screens/languageScreen.dart';
import 'package:grocery_store/screens/registerType.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import 'package:grocery_store/screens/splash_screen.dart';
import 'package:grocery_store/screens/verification_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'localization/language_constants.dart';
import 'localization/set_localization.dart';
import 'screens/home_screen.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  final AuthenticationRepository authenticationRepository =  AuthenticationRepository();
  final UserDataRepository userDataRepository = UserDataRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(
          create: (context) => SignupBloc(
            authenticationRepository: authenticationRepository,
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<SigninBloc>(
          create: (context) => SigninBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),

        BlocProvider<BannerBloc>(
          create: (context) => BannerBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<BannerProductBloc>(
          create: (context) => BannerProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),





        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc(
            userDataRepository: userDataRepository,
          ),
        ),

        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            userDataRepository: userDataRepository,
          ),
        ),

      ],
      child: MyApp(),
    ),
  );
}
class CustomIntegrationListener implements IntegrationListener {
  void onSessionReady(String dashboardSessionUrl) {
    print("DashboardUrl:");
    print(dashboardSessionUrl);
  }

  void onVisitorReady(String dashboardVisitorUrl) {
    print("DashboardVisitorUrl:");
    print(dashboardVisitorUrl);
  }
}
class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(locale);
  }
  static void setTheme(BuildContext context, ThemeData theme) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setTheme(theme);
  }
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String _timeString = "";
  Locale _local;
  bool firstLansh=false;
  String theme;
  ThemeData _theme;
  void setLocale(Locale locale) {
    setState(() {
      _local = locale;
    });
  }
  void setTheme(ThemeData theme) {
    setState(() {
      _theme = theme;
    });
  }
  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._local = locale;
      });
    });
    getTheme().then((theme) {
      setState(() {
        this._theme = theme;
      });
    });
    getFirstLanch().then((ss) {
      setState(() {
        this.firstLansh = ss;
      });
    });

    super.didChangeDependencies();
  }
  @override
  void initState() {
    super.initState();
    _timeString =
    "${DateTime.now().hour} : ${DateTime.now().minute} :${DateTime.now().second}";
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getCurrentTime());
    SetupOptions options =
    (new SetupOptionsBuilder('f038af5d321189c97f4a34259b09a0d13064bcb4')
      ..Fps = 2
      ..StartNewSession = true)
        .build();

    Smartlook.setupAndStartRecording(options);

    Smartlook.setEventTrackingMode(EventTrackingMode.FULL_TRACKING);
    List<EventTrackingMode> eventTrackingModes = [
      EventTrackingMode.FULL_TRACKING,
      EventTrackingMode.IGNORE_USER_INTERACTION
    ];
    Smartlook.setEventTrackingModes(eventTrackingModes);
    Smartlook.registerIntegrationListener(new CustomIntegrationListener());
    Smartlook.setUserIdentifier('FlutterLul', {"flutter-usr-prop": "valueX"});
    Smartlook.setGlobalEventProperty("key_", "value_", true);
    Smartlook.setGlobalEventProperties({"A": "B"}, false);
    Smartlook.removeGlobalEventProperty("A");
    Smartlook.removeAllGlobalEventProperties();
    Smartlook.setGlobalEventProperty("flutter_global", "value_", true);
    Smartlook.enableWebviewRecording(true);
    Smartlook.enableWebviewRecording(false);
    Smartlook.enableCrashlytics(true);
    Smartlook.setReferrer("referer", "source");
    Smartlook.getDashboardSessionUrl(true);
  }
  void _getCurrentTime() {
    setState(() {
      _timeString =
      "${DateTime.now().hour} : ${DateTime.now().minute} :${DateTime.now().second}";
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    if (this._local == null&&this._theme==null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[800])),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jeras',
        locale: _local,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ar', 'AR')
        ],
        localizationsDelegates: [
          SetLocalization.localizationsDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocal, supportedLocales) {
          for(var local in supportedLocales) {
            if(local.languageCode == deviceLocal.languageCode && local.countryCode == deviceLocal.countryCode) {
              return deviceLocal;
            }
          }
          return supportedLocales.first;
        },
        theme: _theme,
       /* theme:ThemeData(
          //primarySwatch: Colors.white10,
          primaryColorDark:Color(0xFF983b7f),// Color(0xFF7936ff),

        primaryColor: Color(0xFF983b7f),
          accentColor: Colors.pink,
          backgroundColor: Colors.white,
          canvasColor: Colors.white,
          unselectedWidgetColor: Colors.black,
        )*/
       /* darkTheme: _dark,
        theme: _light,
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,*/
        initialRoute: '/',
        routes: {
         // '/': (context) => DashboardScreen(),

          '/': (context) => firstLansh?LanguageScreen():SplashScreen(),
          '/verification': (context) => VerificationScreen(),
          '/RegisterTypeScreen': (context) =>RegisterTypeScreen(),
          '/home': (context) => HomeScreen(),
          '/sign_up': (context) => SignUpScreen(),
          '/Register_Type': (context) =>RegisterTypeScreen(),
          '/sign_in': (context) => SignInScreen(),
          //'/NameScreen': (context) =>  NameScreen(),
          '/ForceUpdateScreen': (context) =>ForceUpdateScreen(),
          '/AppointmentChatScreen': (context) =>AppointmentChatScreen(),
        },
      );
    }
  }
}
