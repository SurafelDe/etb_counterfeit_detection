import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';
import 'package:money_classification/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

import 'loading.dart';

void main() {
  Loading.init();

  runApp(
      MaterialApp(
        home: const App(),
        builder: EasyLoading.init(),
      )
  );
}

const String dense121 = "Dense121";
const String inceptionV3 = "InceptionV3";
const String vgg16 = "Vgg16";
// const String vgg19 = "Vgg19";

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _image;
  List? _recognitions;
  String _model = dense121;
  bool _busy = false;
  bool _isGenuine = false;

  Future predictImagePicker() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() {
        _busy = true;
        _image = File(image.path);
        EasyLoading.show();
      });
      predictImage(File(image.path));
    }
    catch(ex, stack) {
      print(ex);
    }
  }
  openCamera() {
    try {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CameraApp(cameraImageCallback: (path) {
        // if (path == null) return;
        Navigator.pop(context);

        setState(() {
          _busy = true;
          _image = File(path);
          EasyLoading.show();
        });
        predictImage(File(path));
      })));

    }
    catch(ex, stack) {
      print(ex);
    }
  }

  Future predictImage(File? image) async {
    try {
      if (image == null) return;

      await recognizeImage(image);

      FileImage(image)
          .resolve(const ImageConfiguration());

      setState(() {
        // _image = image;
        _busy = false;
        EasyLoading.dismiss();
      });
    }
    catch(ex, stack) {
      print(ex);
    }

  }

  @override
  void initState() {
    super.initState();
    try {
      _busy = true;
      EasyLoading.show();

      loadModel().then((val) {
        setState(() {
          _busy = false;
          EasyLoading.dismiss();
        });
      });
    }
    catch(ex, stack) {
      print(ex);
    }

  }

  Future loadModel() async {
    try {
      Tflite.close();
      try {
        String? res;
        switch (_model) {
          case dense121:
            res = await Tflite.loadModel(
              model: "assets/dense121.tflite",
              labels: "assets/labels.txt",
              // useGpuDelegate: true,
            );
            break;
          case inceptionV3:
            res = await Tflite.loadModel(
              model: "assets/InceptionV3.tflite",
              labels: "assets/labels.txt",
              // useGpuDelegate: true,
            );
            break;
          case vgg16:
            res = await Tflite.loadModel(
              model: "assets/Vgg16.tflite",
              labels: "assets/labels.txt",
              // useGpuDelegate: true,
            );
            break;
          // case vgg19:
          //   res = await Tflite.loadModel(
          //     model: "assets/Vgg19.tflite",
          //     // useGpuDelegate: true,
          //   );
          //   break;
          default:
            res = await Tflite.loadModel(
              model: "assets/dense121.tflite",
              labels: "assets/labels.txt",
              // useGpuDelegate: true,
            );
        }
        print(res);
      } on PlatformException {
        print('Failed to load model.');
      }
    }
    catch(ex, stack) {
      print(ex);
    }

  }

  Future recognizeImage(File image) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 6,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _recognitions = recognitions!;
        _isGenuine = recognitions.first?["label"]?.toString().contains("genuine") ?? false;
      });
    }
    catch(ex, stack) {
      print(ex);
    }

  }

  onSelect(model) async {
    try {
      setState(() {
        _busy = true;
        EasyLoading.show();
        _model = model;
        _recognitions = null;
      });
      await loadModel();

      if (_image != null) {
        predictImage(_image!);
      } else {
        setState(() {
          _busy = false;
          EasyLoading.dismiss();
        });
      }
    }
    catch(ex, stack) {
      print(ex);
    }

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 15, top: 50, bottom: 20),
            child: Text(
                "ETB Counterfeit Detector",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Text(
                    "Selected model : ",
                    style: TextStyle(fontSize: 18),
                  ),
                  PopupMenuButton(
                      position: PopupMenuPosition.under,
                      itemBuilder: (context) {
                        List<PopupMenuEntry<String>> menuEntries = [
                          const PopupMenuItem<String>(
                            value: dense121,
                            child: Text(dense121),
                          ),
                          const PopupMenuItem<String>(
                            value: inceptionV3,
                            child: Text(inceptionV3),
                          ),
                          const PopupMenuItem<String>(
                            value: vgg16,
                            child: Text(vgg16),
                          ),
                          // const PopupMenuItem<String>(
                          //   value: vgg19,
                          //   child: Text(vgg19),
                          // ),
                        ];
                        return menuEntries;
                      },
                      onSelected: onSelect,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                _model,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Icon(
                                Icons.expand_more,
                                size: 30,
                              ),
                            ],
                          ))),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 7,
            child: _image == null
                ? noImageSelected()
                : Column(
                  children: [
                    Image.file(
                      _image!,
                      height: size.height/2,
                      fit: BoxFit.scaleDown,
                    ),
                  ],
                ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 3,
            child: _recognitions != null && !_busy
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Lottie.asset(_isGenuine ? "assets/lottie/genuine.json" : "assets/lottie/counterfeit.json", height: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${getResultName(_recognitions?.first?["label"])} with "
                                  "${(_recognitions?.first?["confidence"] *100).toStringAsFixed(2)}% Confidence",
                              style: TextStyle(
                                color: _isGenuine ? Colors.green : Colors.red,
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30,),
                      _isGenuine ? Container() :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(
                            onPressed: () {},
                            elevation: 1,
                            height: 55,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            color: Colors.blueAccent,
                            child: Row(
                              children: const [
                                Icon(Icons.local_police),
                                SizedBox(width: 4,),
                                Text(
                                  'Report to authority',
                                  style:  TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10,),
                          MaterialButton(
                            onPressed: () {},
                            elevation: 1,
                            height: 55,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            color: Colors.green,
                            child: Row(
                              children: const [
                                Icon(Icons.location_pin),
                                SizedBox(width: 4,),
                                Text(
                                  'Share Location',
                                  style:  TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ]
                  ),
                ) : Container()
          ),

        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // _image != null ?
              FloatingActionButton(
                heroTag: "file",
                onPressed: predictImagePicker,
                tooltip: 'Pick Image',
                child: const Icon(Icons.image),
              ),
                //  : Container(),
              const SizedBox(width: 10,),
              FloatingActionButton(
                heroTag: "camera",
                onPressed: openCamera,
                tooltip: 'Take Photo',
                child: const Icon(Icons.camera_alt),
              ),
            ],
          ),
    );
  }

  Widget noImageSelected() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 160, left: 50, right: 50, bottom: 65),
        height: MediaQuery.of(context).size.height - 140,
        child: DottedBorder(
          padding: const EdgeInsets.all(10),
          radius: Radius.circular(10),
          color: Colors.blueAccent,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: predictImagePicker,
                    child:
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Lottie.asset('assets/lottie/add_image.json', height: 150),
                        )),
                const Text(
                  'Select image to test OR',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10,),
                FloatingActionButton(
                  heroTag: "dcamera",
                  elevation: 0,
                  onPressed: openCamera,
                  tooltip: 'Take Photo',
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
        ),
      ),
    );
  }

  String getResultName(String label) {
    switch(label) {
      case "genuine_200_etb" :
        return "Genuine 200 ETB";
      case "counterfeit_200_etb" :
        return "Counterfeit 200 ETB";
      case "genuine_100_etb" :
        return "Genuine 100 ETB";
      case "counterfeit_100_etb" :
        return "Counterfeit 100 ETB";
      default:
        return "unknown";
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
