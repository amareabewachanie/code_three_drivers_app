import 'package:flutter/material.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import '../widget/profile_design_ui.dart';
class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);
  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the user name
            Text(onlineDriverData.name!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(titleStarsRating+" Driver",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
            ),
            const SizedBox(height: 38,),
            InfoDesignUIWidget(
              textInfo: onlineDriverData.phone!,
              iconData: Icons.phone_iphone,
            ),
            InfoDesignUIWidget(
              textInfo: onlineDriverData.email!,
              iconData: Icons.email,
            ),
            InfoDesignUIWidget(
              textInfo: onlineDriverData.car_color!+ " "+onlineDriverData.car_model!+ " "+onlineDriverData.car_number!,
              iconData: Icons.car_repair,
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.black
                ),
                onPressed: (){
                  fAuth.signOut();
                       Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));
                },
                child: const Text("Sign Out",
                  style: TextStyle(
                      color: Colors.white
                  ),))
          ],
        ),
      ),
    );
    // return  Center(
    //   child: ElevatedButton(
    //       onPressed: ()  {
    //      fAuth.signOut();
    //      Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));
    //   },
    //       child: const Text("Sign Out")
    //   )
    // );
  }
}
