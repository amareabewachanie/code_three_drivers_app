
import 'package:drivers_app/global/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class FareAmounCollectionDialog extends StatefulWidget {
  double? totalFareAmount;
  FareAmounCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmounCollectionDialog> createState() => _FareAmounCollectionDialogState();
}

class _FareAmounCollectionDialogState extends State<FareAmounCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14)
      ),
      backgroundColor: Colors.green,
      child: Container(
        margin:const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20,),
             Text("Tripe Fare Amount "+"{"+driverVehicleType!.toUpperCase()+"}",
             style:const TextStyle(
               fontWeight: FontWeight.bold,
               color: Colors.grey,
               fontSize: 16
             ),
             ),
            const SizedBox(height: 20,),
            const Divider(
              thickness: 4,
              color: Colors.green,
            ),
        const SizedBox(height: 20,),
            Text(widget.totalFareAmount.toString()+" ETB ONLY",
              style: const TextStyle(
              fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.grey
            ),
            ),
            const SizedBox(height: 10),
            const Padding(
             padding:  EdgeInsets.all(8.0),
             child:  Text("This is the total trip amount, Please collect it from the user",
              textAlign: TextAlign.center,style: TextStyle(
                  color: Colors.grey,
                ),),
           ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green
                ),
                  onPressed: (){
                Future.delayed(const Duration(milliseconds: 2000),(){
                  SystemNavigator.pop();
                });
              },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      const Text("Collect Cash",style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      ),
                      Text(widget.totalFareAmount!.toString()+" Birr",
                        style:const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ))
                    ],
                  )
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),

      ),
    );
  }
}
