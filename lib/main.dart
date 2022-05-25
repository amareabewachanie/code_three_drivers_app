
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
   child: ChangeNotifierProvider(
     create: (context)=>AppInfo(),
     child: MaterialApp(
       locale: Locale("am"),
       localizationsDelegates:const [
         S.delegate,
         GlobalMaterialLocalizations.delegate,
         GlobalWidgetsLocalizations.delegate,
         GlobalCupertinoLocalizations.delegate,
       ],
       supportedLocales: S.delegate.supportedLocales,
       title: 'Flutter Demo',
       theme: ThemeData(
           primarySwatch: Colors.green
       ),
       home:const MySplashScreen(),
       debugShowCheckedModeBanner: false,
     ),
   )
  ));
}

class MyApp extends StatefulWidget {
final Widget? child;
 MyApp({this.child});
 static void restartApp(BuildContext context){
   context.findAncestorStateOfType<_MyAppState>()!.restartApp();
 }
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key=UniqueKey();
  void restartApp(){
    setState(() {
      key=UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
        key: key,child: widget.child!
    );
  }
}
