import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tensorflow/Widget/ShowDailog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  File _image;
  List _output;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadModel().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future getImage(source) async {
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        isLoading = true;
        runModelOnImage(_image);
      } else {
        print('No image selected.');
      }
    });
  }

  //dialogbox
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return ShowDialog(
          firstPress: () {
            getImage(ImageSource.camera);
            Navigator.pop(context);
          },
          secondPress: () {
            getImage(ImageSource.gallery);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Tensorflow"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //image
          _image != null
              ? Container(
                  width: size.width,
                  child: Image(
                    height: size.height * 0.6,
                    fit: BoxFit.contain,
                    image: FileImage(_image),
                  ),
                )
              : Container(),

          //result text
          _image != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "${double.parse(((_output[0]['confidence']) * 100).toString()).toStringAsFixed(2)} %",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.yellow,
                      ),
                    ),
                    Text(
                      "${_output[0]['label']}",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMyDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  runModelOnImage(File currentImg) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: currentImg.path, // required
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _output = recognitions;
        isLoading = false;
      });
    } catch (e) {
      print("Error occure in runModelOnImage : ${e.toString()}");
    }
  }

  loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
      );
    } catch (e) {
      print("Error occure in LoadAssets: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
