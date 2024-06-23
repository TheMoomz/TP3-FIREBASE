import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:tp1_flutter/DTOs/transfer.dart';
import 'package:tp1_flutter/http.dart';
import 'package:tp1_flutter/main.dart';

import 'accueil.dart';
import 'creation.dart';
import 'generated/l10n.dart';

class Details extends StatefulWidget {
  const Details({super.key, required this.taskid});

  final int taskid;


  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  final picker = ImagePicker();
  String pathImg = "";
  String imgURL = "";
  Image? imgSelected = null;

  XFile? _imageFile;

  String nameOfTask = "";
  int photoID = 0;
  int _currentSliderValue = 0;
  double timeLeftPerc = 0;
  DateTime deadlineTask = DateTime.now();

  int initialProg = 0;



  void PickImg() async{
    _imageFile = await picker.pickImage(source: ImageSource.gallery);
    ProgressDialog pd = ProgressDialog(context: context);
    if(_imageFile != null){
      pathImg = _imageFile!.path;
      imgSelected = Image.file(File(pathImg));

    }
    setState(() {

    });
    pd.close();

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetTask();
  }

  GetTask()    async{
    ProgressDialog pd = ProgressDialog(context: context);
    SchedulerBinding.instance.addPostFrameCallback((_) => pd.show(msg: S.of(context).loading, barrierColor: MyColorScheme.myBarrierColor));
    //TaskDetailResponse tdr = await SeeTask(widget.taskid);
    TaskDetailPhotoResponse tdr = await SeeTaskPhoto(widget.taskid);
    setState(() {

    });
    nameOfTask = tdr.name;
    initialProg = tdr.percentageDone;
    _currentSliderValue = tdr.percentageDone;
    timeLeftPerc = tdr.percentageTimeSpent;
    deadlineTask = tdr.deadline;
    if(tdr.photoId != 0){

      photoID = tdr.photoId;

      imgURL = "http://10.0.2.2:8080/file/$photoID?width=150";

      imgSelected = Image.network(imgURL);
    }
    pd.close();
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
                    "Salut, "+
                        SingletonDIO.pseudoSingleton+"!",
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
                    await Logout();
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
              color: MyColorScheme.myTertiaryColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MyColorScheme.myPrimaryColor)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                nameOfTask, textAlign: TextAlign.center, style: MyTypography.myDisplayStyleDark,
              ),
              Text(
                S.of(context).percTimeSpent(timeLeftPerc.toString()), textAlign: TextAlign.center, style: MyTypography.myHeadingStyle,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                  S.of(context).percDone(_currentSliderValue.toString()), textAlign: TextAlign.center, style: MyTypography.myBodyStyleDark,
                  ),
                  Slider(
                    value: _currentSliderValue.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value.toInt();
                      });
                    },
                  ),
                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(onPressed: ()async {
                    PickImg();

                  }, child:
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Icon(Icons.image),
                    Text(S.of(context).photoLibrary, textAlign: TextAlign.center, style: MyTypography.myBodyStyle)
                  ],)),
                  (pathImg == "" && imgURL == "")?
                  SizedBox(
                    height: 150,
                      width: 150,
                      child: Text(S.of(context).selectImg, textAlign: TextAlign.center, style: MyTypography.myBodyStyleDark))
                      :SizedBox(
                    height: 150,
                    width: 150,
                    child: (pathImg == "")? CachedNetworkImage(
                      imageUrl: imgURL,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ):
                        imgSelected
                  )

                ],
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  TextButton(onPressed: (){
                    NavigationHelper().navigateTo(context, Accueil());
                  }, child: Text(S.of(context).back, style: MyTypography.myBodyStyle,)),
                  FilledButton(onPressed: () async{
                    pd.show(msg: S.of(context).loading, barrierColor: MyColorScheme.myBarrierColor);
                    if(pathImg != ""){
                      await sendImg(pathImg, widget.taskid);
                    }
                    if(_currentSliderValue != initialProg){
                      await ChangeProgress(widget.taskid, _currentSliderValue.toInt());
                    }
                    pd.close();
                    NavigationHelper().navigateTo(context, Accueil());
                  }, child: Text(
                    S.of(context).editProgress, style: MyTypography.myBodyStyleLight,
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