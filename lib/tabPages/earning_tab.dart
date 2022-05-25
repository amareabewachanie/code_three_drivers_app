import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/mainScreens/tips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({Key? key}) : super(key: key);

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        children: [
          Container(
            color: Colors.green,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children:  [
                   const Text("Your Earnings:",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),),
                  const SizedBox(height: 10,),
                  Text(Provider.of<AppInfo>(context,listen: false).driverTotalEarnings,
                    style:const TextStyle(
                      color: Colors.black,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),),
                ],
              ),
            ),
          ),
         ElevatedButton(
           style: ElevatedButton.styleFrom(
             primary: Colors.black54
           ),
             onPressed: (){
             Navigator.push(context, MaterialPageRoute(builder: (c)=>TripsHistoryScreen()));
             },
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
               child: Row(
                 children: [
                   Image.asset("images/car_logo.png",
                   width: 100,),
                   const SizedBox(width: 20,),
                   const Text("Trips Completed",
                   ),
                   Expanded(
                     child: Container(
                       child:  Text(Provider.of<AppInfo>(context,listen:false).listOfTripHistories.length.toString(),
                       textAlign: TextAlign.end,
                       style: const TextStyle(
                         fontSize: 20,
                         fontWeight: FontWeight.bold,
                         color: Colors.white
                       ),),
                     ),
                   )
                 ],
               ),
             ))
        ],
      ),
    );
  }
}
