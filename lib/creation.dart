import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:tp1_flutter/accueil.dart';
import 'package:tp1_flutter/main.dart';

import 'firebase.dart';
import 'generated/l10n.dart';

class Creation extends StatefulWidget {
  const Creation({super.key});

  @override
  State<Creation> createState() => _CreationState();
}

class _CreationState extends State<Creation> {

  final TextEditingController nomTask = TextEditingController();

  DateTime selectedDate = DateTime.now().add(Duration(hours: 4));

  String formattedDate = "";



  Future<void> _selectDate(BuildContext context) async {

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().add(Duration(hours: 4)), // limite inf de date
        lastDate: DateTime(2101)); // limite sup de date
    if (picked != null && picked != selectedDate.toUtc()) {
      setState(() {
        selectedDate = picked.add(Duration(hours: 4));
        formattedDate = selectedDate.day.toString() +"/"+ selectedDate.month.toString() +"/"+ selectedDate.year.toString();
      });
    }
  }

  Future<bool> creationTask() async{

    String checking = await checkFields();
    if(checking != "ok"){
      Fluttertoast.showToast(msg: await checkFields());

      return false;

    }

    await addTask(nomTask.text.trim(), Timestamp.fromDate(selectedDate));


    return true;

  }

  Future<String> checkFields() async {

    if(nomTask.text.isEmpty || nomTask.text.trim() == ""){
      return S.of(context).tasknameEmpty;
    }

    if(nomTask.text.length < 2){
      return S.of(context).tasknameTooShort;
    }


    //TODO : FIND A WAY TO CHECK IF NAME IS ALREADY TAKEN


    var res = await getTaskCollection().get();
    var tasksDocs = res.docs;

    setState(() {

    });

    List list = tasksDocs.toList();

    for(var item in list){
      String trimmed = item['name'];
      if(trimmed.trim() == nomTask.text.trim()){
        return S.of(context).tasknameTaken;
      }
    }

    

    return "ok";

  }

  void initFirebase() async{
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    initFirebase();
  }

  @override
  Widget build(BuildContext context) {

    ProgressDialog pd = ProgressDialog(context: context);

    return Scaffold(
        appBar: AppBar(
      backgroundColor: Colors.white,
    ),
      drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: MyColorScheme.myPrimaryColor,
                  ),
                  child: Text(
                    ((FirebaseAuth.instance.currentUser)?.displayName.toString() == null ? "" : S.of(context).hiUser((FirebaseAuth.instance.currentUser)!.displayName.toString())),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(S.of(context).home),
                  onTap: () async {
                    await NavigationHelper().navigateTo(context, Accueil());
                  }
                  ,
                ),
                ListTile(
                  title: Text(S.of(context).createTask),
                  onTap: () async{
                    await NavigationHelper().navigateTo(context, Creation());
                  }
                  ,
                ),
                ListTile(
                  title: Text(S.of(context).logout),
                  onTap: () async {
                    pd.show(msg: S.of(context).loading, barrierColor: MyColorScheme.myBarrierColor);
                    await GoogleSignIn().signOut();
                    await FirebaseAuth.instance.signOut();
                    setState(() {});
                    pd.close();
                    await NavigationHelper().home(context);
                  }
                  ,
                )
              ]
          )
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 550,
          margin: EdgeInsets.fromLTRB(10, 30, 10, 80),
          padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
          decoration: BoxDecoration(
            color: MyColorScheme.myAccentColorPale,
            borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MyColorScheme.myAccentColor)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                S.of(context).createTask, textAlign: TextAlign.center, style: MyTypography.myHeadingStyle,
              ),
              TextFormField(
                controller: nomTask,
                decoration: InputDecoration(
                    hintStyle: MyTypography.myHintStyle,
                    labelStyle: MyTypography.myLabelStyle,
                    labelText: S.of(context).nameTask,
                    border: OutlineInputBorder(
                    ),
                    hintText:  S.of(context).hintUsername,
                    fillColor: Colors.white,
                    filled: true
                ),
              ),
              OutlinedButton(onPressed: () => _selectDate(context), child:
              Text(
                S.of(context).selectDate, style: MyTypography.myBodyStyle,
              )),
              Text(formattedDate, style: MyTypography.myBodyStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  TextButton(onPressed: (){
                    NavigationHelper().navigateTo(context, Accueil());
                  }, child: Text(S.of(context).back, style: MyTypography.myBodyStyle,)),
                  ElevatedButton(onPressed: () async{
                    pd.show(msg: S.of(context).loading, barrierColor: MyColorScheme.myBarrierColor);

                    bool added = await creationTask();

                    pd.close();

                    if(added){
                      NavigationHelper().navigateTo(context, Accueil());
                    }




                  }, child: Text(
                    S.of(context).create, style: MyTypography.myBodyStyleLight,
                  ))
                ],
              )

            ],
          ),
        ),
      ),
        resizeToAvoidBottomInset: false// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}