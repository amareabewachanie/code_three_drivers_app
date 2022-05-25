import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trips_history_model.dart';

class HistoryDesignUiWidget extends StatefulWidget {
  TripsHistoryModel? tripsHistoryModel;
  HistoryDesignUiWidget({this.tripsHistoryModel});

  @override
  State<HistoryDesignUiWidget> createState() => _HistoryDesignUiWidgetState();
}

class _HistoryDesignUiWidgetState extends State<HistoryDesignUiWidget> {
  String formatDateAndTime(String dateTimeFromDB){
    DateTime dateTime=DateTime.parse(dateTimeFromDB);
   String formatdDateTime= "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
   return formatdDateTime;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Driver Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text("Passenger : "+widget.tripsHistoryModel!.userName!,
                  style:const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),),
                ),
                const SizedBox(width: 12,),
                Text(
                  widget.tripsHistoryModel!.fareAmount!+" ETB",
                  style: const TextStyle(
                        fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(height: 2,),
            //Car details
            Row(
              children: [
                const Icon(Icons.phone_android_rounded,
                color: Colors.grey,),
                const SizedBox(width: 12,),
                Expanded(
                  child: Text(
                    widget.tripsHistoryModel!.userPhone!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20,),
            // Pickup address
            Row(
              children: [
                Image.asset(
                  "images/origin.png",
                   height: 26,
                    width: 26,
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: Text(widget.tripsHistoryModel!.originAddress!,
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),),
                )

              ],
            ),
            const SizedBox(height: 14,),
            // Destination address
            Row(
              children: [
                Image.asset(
                  "images/destination.png",
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: Container(
                    child: Text(widget.tripsHistoryModel!.destinationAddress!,
                      overflow: TextOverflow.ellipsis,
                      style:const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                )

              ],
            ),
            const SizedBox(height: 14,),
            // Trip time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(
                  formatDateAndTime(widget.tripsHistoryModel!.time!),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14,),
          ],
        ),
      ),
    );
  }
}
