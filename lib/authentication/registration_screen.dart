import 'package:drivers_app/authentication/carinfo_screen.dart';
import 'package:drivers_app/widget/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameTextEditingController=TextEditingController();
  TextEditingController emailTextEditingController=TextEditingController();
  TextEditingController passwordTextEditingController=TextEditingController();
  TextEditingController phoneTextEditingController=TextEditingController();
   validateUserInput(){
    if(nameTextEditingController.text.length<3){
      Fluttertoast.showToast(msg: "Name must be at least 3 characters");
    }else if(emailTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Email must not be empty");
    }
    else if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Invalid Email");
    }else if(phoneTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Phone number can not be null");
    }else if(passwordTextEditingController.text.length<6){
      Fluttertoast.showToast(msg: "Password must be greater than 6 characters long");
    }else{
      saveDriverInfo();
    }
  }
  saveDriverInfo() async{
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Processing Please wait..");
        });
    final User? firebaseUser=(
    await fAuth.createUserWithEmailAndPassword(
        email:emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim()
    ).catchError((msg){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error"+msg.toString());
    })
    ).user;
    if(firebaseUser !=null){
     Map driversMap={
       "id":firebaseUser.uid,
       "name":nameTextEditingController.text.trim(),
       "email":emailTextEditingController.text.trim(),
       "phone":phoneTextEditingController.text.trim()
     };
     DatabaseReference driversRef=FirebaseDatabase.instance.ref().child("drivers");
     driversRef.child(firebaseUser.uid).set(driversMap);
     currentFirebaseUser=firebaseUser;
     Fluttertoast.showToast(msg: "Account has been created");
     Navigator.push(context, MaterialPageRoute(builder: (c)=>const CarInfoScreen()));
    }else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been created");
    }
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.png"),
              ),
              const SizedBox(height: 10,),
              const Text("Register As A Driver",style: TextStyle(
                fontSize: 24,
                color: Colors.grey,
                fontWeight: FontWeight.bold
              )),
              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(
                color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  hintText: "Full Name",
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
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Phone Number",
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
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
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
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                    color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
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
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
               // Save User Data to Firebase
                saveDriverInfo();
              },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent
                  ),
                  child:
                const Text("Create Account",style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18
                ),)
              ),
              const SizedBox(height: 20,),
              TextButton(
                  onPressed: (){
                    // Validate user inputs
                    validateUserInput();
                    // Save User Data to Firebase
                   // Navigator.push(context, MaterialPageRoute(builder: (c)=>const LoginScreen()));
                  },
                  child:
                  const Text("Already have an account? Login Now",style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18
                  ),)
              )
            ],
          ),
        ),
      ),
    );
  }
}
