
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/main_screen.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({Key? key}) : super(key: key);

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController modelTextEditingController=TextEditingController();
  TextEditingController numberTextEditingController=TextEditingController();
  TextEditingController colorTextEditingController=TextEditingController();
  List<String> carTypesList=['Normal','MiniVas','Lexury','Motor','Byscle'];
  String? selectedCarType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.png"),
              ),
              const SizedBox(height: 10,),
              const Text("Car Details",style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
              )),
              TextField(
                controller: modelTextEditingController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Car Model",
                  hintText: "Car Model",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              TextField(
                controller: numberTextEditingController,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Plate Number",
                  hintText: "Plate Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              TextField(
                controller: colorTextEditingController,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Car Color",
                  hintText: "Car Color",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10
                  ),
                  labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              DropdownButton(
                iconSize: 26,
                dropdownColor: Colors.black,
                hint:const Text("Please choose your car type",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey
                ),
                ),
                  value: selectedCarType,
                  onChanged: (newValue){
                    setState(() {
                      selectedCarType=newValue.toString();
                    });
                  },
              items: carTypesList.map((car){
                return DropdownMenuItem(
                child: Text(car,style: const TextStyle(color: Colors.grey),),
                  value: car,
                );
    }).toList(),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                // Save User Data to Firebase
                saveCarInfo();
              },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.lightGreenAccent
                  ),
                  child:
                  const Text("Save Now",style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18
                  ),)
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveCarInfo() {
    if(modelTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Model Can' be null");
    }else if(numberTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Plate Number Should not be null");
    }else if(colorTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Color Should not be null");
    }
    else if(selectedCarType!.isEmpty){
      Fluttertoast.showToast(msg: "Please select your service type");
    }else{
      registerCar();
    }
  }
  void registerCar() {
    Map driverCarInfoMap={
      "car_color":colorTextEditingController.text.trim(),
      "car_number":numberTextEditingController.text.trim(),
      "car_model":modelTextEditingController.text.trim(),
      "type":selectedCarType
    };
    DatabaseReference driversRef=FirebaseDatabase.instance.ref().child("drivers");
    driversRef.child(currentFirebaseUser!.uid).child("car_details").set(driverCarInfoMap);
    Fluttertoast.showToast(msg: "Car Detail has been saved,Congratulations!");
    Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));
  }
}
