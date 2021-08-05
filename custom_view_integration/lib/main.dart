import 'package:document_detector/android/android_settings.dart';
import 'package:document_detector/android/capture_stage/capture_mode.dart';
import 'package:document_detector/android/capture_stage/capture_stage.dart';
import 'package:document_detector/android/customization.dart';
import 'package:document_detector/message_settings.dart' as MessageSettingsDoc;
import 'package:document_detector/show_preview.dart' as ShowPreviewDoc;
import 'package:document_detector/document_detector_step.dart';
import 'package:document_detector/document_type.dart';
import 'package:document_detector/ios/ios_settings.dart';
import 'package:document_detector/result/capture.dart';
import 'package:document_detector/result/document_detector_failure.dart';
import 'package:document_detector/result/document_detector_result.dart';
import 'package:document_detector/result/document_detector_success.dart';
import 'package:document_detector/document_detector.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passive_face_liveness/android/customization.dart';

import 'package:passive_face_liveness/android/settings.dart';
import 'package:passive_face_liveness/show_preview.dart';
import 'package:passive_face_liveness/passive_face_liveness.dart';
import 'package:passive_face_liveness/result/passive_face_liveness_failure.dart';
import 'package:passive_face_liveness/result/passive_face_liveness_result.dart';
import 'package:passive_face_liveness/result/passive_face_liveness_success.dart';
import 'package:passive_face_liveness/message_settings.dart';

import 'package:face_authenticator/face_authenticator.dart';
import 'package:face_authenticator/result/face_authenticator_failure.dart';
import 'package:face_authenticator/result/face_authenticator_result.dart';
import 'package:face_authenticator/result/face_authenticator_success.dart';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = "";
  String _description = "";

  String peopleId = "";

  String mobileToken = "";
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    await [
      Permission.camera,
    ].request();
  }

  //DocumentDetector
  void startDocumentDetector(List<DocumentDetectorStep> documentSteps) async {
    String result = "";
    String description = "";

    DocumentDetector documentDetector =
        new DocumentDetector(mobileToken: mobileToken);

    DocumentDetectorCustomizationAndroid customDocAndroid =
        new DocumentDetectorCustomizationAndroid(
            whiteMaskResIdName: "document_whitemask",
            greenMaskResIdName: "document_greenmask",
            redMaskResIdName: "document_redmask");

    DocumentDetectorAndroidSettings androidSettings =
        new DocumentDetectorAndroidSettings(customization: customDocAndroid);
    //Custom showPreview
    ShowPreviewDoc.ShowPreview showPreview = new ShowPreviewDoc.ShowPreview(
        show: true,
        title: "A foto está legal?",
        subTitle:
            "Veja se todas informações estão legíveis, facilitando assim, sua aprovação",
        confirmLabel: "Está boa, quero esta!",
        retryLabel: "Tirar outra foto");

    //Custom messageSettings
    MessageSettingsDoc.MessageSettings messageSettings =
        new MessageSettingsDoc.MessageSettings(
            holdItMessage: "Segure seu dispositivo desta forma",
            lowQualityDocumentMessage:
                "A qualidade não está boa. Não conseguimos ler, tire outra",
            uploadingImageMessage: "Salvando sua foto...",
            verifyingQualityMessage: "Verificando qualidade da foto...");

    documentDetector.setShowPreview(showPreview);

    documentDetector.setMessageSettings(messageSettings);

    documentDetector.setDocumentFlow(documentSteps);

    //You can use other paramethers to customization here
    //Check what we offer on our documentation: https://github.com/combateafraude/Flutter/tree/document-detector

    //Check for the success on DocumentDetector executation
    try {
      DocumentDetectorResult documentResult = await documentDetector.start();

      if (documentResult is DocumentDetectorSuccess) {
        result = "Success!";
        print(DocumentType);
        description = "Type: " +
            (documentResult.type != null ? documentResult.type : "null");

        for (Capture capture in documentResult.captures) {
          description += "\n\n\tCapture:\n\timagePath: " +
              capture.imagePath +
              "\n\timageUrl: " +
              (capture.imageUrl != null
                  ? capture.imageUrl.split("?")[0] + "..."
                  : "null") +
              "\n\tlabel: " +
              (capture.label != null ? capture.label : "null") +
              "\n\tquality: " +
              (capture.quality != null ? capture.quality.toString() : "null");
        }
      } else if (documentResult is DocumentDetectorFailure) {
        result = "Falha!";
        description = "\tType: " +
            documentResult.type +
            "\n\tMessage: " +
            documentResult.message;
        print(DocumentType);
      } else {
        result = "Closed!";
      }
    } on PlatformException catch (err) {
      result = "Excpection!";
      description = err.message;
    }

    if (!mounted) return;

    setState(() {
      _result = result;
      _description = description;
    });
  }

  //Passive Face Liveness
  void startPassiveFaceLiveness() async {
    String result = "";
    String description = "";

    PassiveFaceLiveness passiveFaceLiveness =
        new PassiveFaceLiveness(mobileToken: mobileToken);

    //Custom showPreview
    ShowPreview showPreview = new ShowPreview(
      show: true,
      title: "A foto está legal?",
      subTitle:
          "Veja se todas informações estão legíveis, facilitando assim, sua aprovação",
      confirmLabel: "Está boa, quero esta!",
      retryLabel: "Tirar outra foto",
    );

    //Custom messageSettings
    MessageSettings messageSettings = new MessageSettings(
      faceNotFoundMessage: "Não encontramos um rosto em nossa base de dados",
      faceTooFarMessage: "Aproxima o teu rosto",
      faceTooCloseMessage: "Afasta o teu rosto",
      faceNotFittedMessage: "Encaixe o teu rosto",
      verifyingLivenessMessage: "Verificando a tua selfie...",
      holdItMessage: "Segure seu dispositivo desse jeito",
    );

    PassiveFaceLivenessCustomizationAndroid costumizationAndroid =
        new PassiveFaceLivenessCustomizationAndroid(
            whiteMaskResIdName: "face_whitemask",
            greenMaskResIdName: "face_greenmask",
            redMaskResIdName: "face_redmask");

    //Custom ButtonTime and Layout
    PassiveFaceLivenessAndroidSettings passiveFaceLivenessAndroidSettings =
        new PassiveFaceLivenessAndroidSettings(
            showButtonTime: 25000, customization: costumizationAndroid);
    //The button time is defined on Milliseconds. ex: 25000 --> 25seg

    passiveFaceLiveness.setShowPreview(showPreview);

    passiveFaceLiveness.setAndroidSettings(passiveFaceLivenessAndroidSettings);

    passiveFaceLiveness.setMessageSettings(messageSettings);

    //You can use other paramethers to customization here
    //Check what we offer on our documentation: https://github.com/combateafraude/Flutter/tree/passive-face-liveness

    //Check for the success on PassiveFaceLiveness executation
    PassiveFaceLivenessResult passiveFaceLivenessResult =
        await passiveFaceLiveness.start();

    if (passiveFaceLivenessResult is PassiveFaceLivenessSuccess) {
      result = "Success!";

      description += "\n\timagePath: " +
          passiveFaceLivenessResult.imagePath +
          "\n\timageUrl: " +
          (passiveFaceLivenessResult.imageUrl != null
              ? passiveFaceLivenessResult.imageUrl.split("?")[0] + "..."
              : "null") +
          "\n\tsignedResponse: " +
          (passiveFaceLivenessResult.signedResponse != null
              ? passiveFaceLivenessResult.signedResponse
              : "null");
    } else if (passiveFaceLivenessResult is PassiveFaceLivenessFailure) {
      result = "Falha!";
      description = "\tType: " +
          passiveFaceLivenessResult.type +
          "\n\tMessage: " +
          passiveFaceLivenessResult.message;
    } else {
      result = "Closed!";
    }

    if (!mounted) return;

    setState(() {
      _result = result;
      _description = description;
    });
  }

  //Face Authenticator
  void startFaceAuthenticator() async {
    String result = "";
    String description = "";

    FaceAuthenticator faceAuthenticator =
        new FaceAuthenticator(mobileToken: mobileToken);
    faceAuthenticator.setPeopleId(peopleId);

    //Check for the success on PassiveFaceLiveness executation
    try {
      FaceAuthenticatorResult faceAuthenticatorResult =
          await faceAuthenticator.start();

      if (faceAuthenticatorResult is FaceAuthenticatorSuccess) {
        result = "Success!";

        description += "\n\tauthenticated: " +
            (faceAuthenticatorResult.authenticated ? "true" : "false") +
            "\n\tsignedResponse: " +
            (faceAuthenticatorResult.signedResponse != null
                ? faceAuthenticatorResult.signedResponse
                : "null");
      } else if (faceAuthenticatorResult is FaceAuthenticatorFailure) {
        result = "Failed!";
        description = "\tType: " +
            faceAuthenticatorResult.type +
            "\n\tMessage: " +
            faceAuthenticatorResult.message;
      } else {
        result = "Closed!";
      }
    } on PlatformException catch (err) {
      result = "Excpection!";
      description = err.message;
    }

    if (!mounted) return;

    setState(() {
      _result = result;
      _description = description;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Flutter plugin example'),
            ),
            body: Container(
                margin: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            startDocumentDetector([
                              new DocumentDetectorStep(
                                  document: DocumentType.CNH_FRONT),
                              new DocumentDetectorStep(
                                  document: DocumentType.CNH_BACK)
                            ]);
                          },
                          icon: Icon(Icons.document_scanner),
                          label: Text('DocumentDetector for CNH'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.greenAccent,
                              onSurface: Colors.lightGreenAccent,
                              elevation: 5,
                              shadowColor: Colors.black,
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              textStyle:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            startDocumentDetector([
                              new DocumentDetectorStep(
                                  document: DocumentType.RG_FRONT),
                              new DocumentDetectorStep(
                                  document: DocumentType.RG_BACK)
                            ]);
                          },
                          icon: Icon(Icons.document_scanner),
                          label: Text('DocumentDetector for RG'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.greenAccent,
                              onSurface: Colors.lightGreenAccent,
                              elevation: 5,
                              shadowColor: Colors.black,
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              textStyle:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            startDocumentDetector([
                              new DocumentDetectorStep(
                                  document: DocumentType.RNE_FRONT),
                              new DocumentDetectorStep(
                                  document: DocumentType.RNE_BACK)
                            ]);
                          },
                          icon: Icon(Icons.document_scanner),
                          label: Text('DocumentDetector for RNE'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.greenAccent,
                              onSurface: Colors.lightGreenAccent,
                              elevation: 5,
                              shadowColor: Colors.black,
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              textStyle:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            startPassiveFaceLiveness();
                          },
                          icon: Icon(Icons.person),
                          label: Text('Passive Face Liveness'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.greenAccent,
                              onSurface: Colors.lightGreenAccent,
                              elevation: 5,
                              shadowColor: Colors.black,
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              textStyle:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            startFaceAuthenticator();
                          },
                          icon: Icon(Icons.person),
                          label: Text('Face Authenticator'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.greenAccent,
                              onSurface: Colors.lightGreenAccent,
                              elevation: 5,
                              shadowColor: Colors.black,
                              shape: const BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              textStyle:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Text("Result: $_result"))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("Description:\n$_description",
                              overflow: TextOverflow.clip),
                        )
                      ],
                    ),
                  ],
                ))));
  }
}
