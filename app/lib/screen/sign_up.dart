import 'package:app/components/components.dart';
import 'package:app/model/sign_up_notifier.dart';
import 'package:app/service/contract_provider.dart';
import 'package:app/model/user.dart';
import 'package:app/screen/home.dart';
import 'package:app/service/Firebase_database.dart';
import 'package:app/service/deep_face_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:m7_livelyness_detection/index.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class SignUpPage extends StatefulWidget {
  final String imagePath;
  const SignUpPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  DeepFaceApi? deepFaceApi;
  FirebaseMethods? firebaseInstance;
  String? name, email, id;
  ContractProvider? contractProvider;
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  final _formkey = GlobalKey<FormState>();
  List<User>? registeredUsers;
  late Client httpclient;
  late Web3Client ethClient;
  final String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/1WyDdrv-NGBT-ZafMq8xdadQTPiwFHK6";
  final String wsUrl =
      "wss://eth-sepolia.g.alchemy.com/v2/1WyDdrv-NGBT-ZafMq8xdadQTPiwFHK6";

  SignUpPageProvider? signUpPageProvider;

  @override
  void initState() {
    // TODO: implement initState
    deepFaceApi = DeepFaceApi();
    httpclient = Client();
    ethClient = Web3Client(rpcUrl, httpclient);
    contractProvider = ContractProvider(
        httpclient: httpclient, ethClient: ethClient, context: context);
    firebaseInstance = FirebaseMethods();
    super.initState();
  }

  void registration() async {
    if (_formkey.currentState!.validate()) {
      email = emailController.text;
      name = nameController.text;
      id = Uuid().v1();
      final file = File(widget.imagePath);
      Uint8List fileBytes = file.readAsBytesSync();
      String base64FileBytes = base64Encode(fileBytes);
      Map<String, String> userInformation = {
        "Email": email!,
        "Name": name!,
        "Image": base64FileBytes,
        "Id": id!,
      };
      registeredUsers = await firebaseInstance!.getUsersFromFirestore();
      signUpPageProvider!.registration(registeredUsers!, contractProvider!,
          base64FileBytes, userInformation, id!);
      // if (registeredUsers!.isEmpty) {
      //   try {
      //     firebaseInstance!.addUsers(userInformation);
      //     contractProvider!.registerVoter(id!);
      //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //         backgroundColor: Colors.black,
      //         content: Text(
      //           "Registered Successfully",
      //           style: TextStyle(fontSize: 20, color: Colors.white),
      //         )));
      //     Navigator.pushReplacement(
      //         context, MaterialPageRoute(builder: ((context) => Home())));
      //   } on FirebaseException catch (e) {
      //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       backgroundColor: Colors.black,
      //       content: Text(
      //         "Firebase Errors, check your internet connection",
      //         style: TextStyle(color: Colors.white, fontSize: 18),
      //       ),
      //     ));
      //   }
      // } else if (registeredUsers!.isNotEmpty) {
      //   for (var i = 0; i < registeredUsers!.length; i++) {
      //     bool reply = await deepFaceApi!
      //         .verifyFace(base64FileBytes, registeredUsers![i].image);
      //     if (reply == true) {
      //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //           backgroundColor: Colors.black,
      //           content: Text(
      //             "You are already Registered!",
      //             style: TextStyle(fontSize: 20, color: Colors.white),
      //           )));
      //       Navigator.pushReplacement(
      //           context, MaterialPageRoute(builder: ((context) => Home())));
      //       break;
      //     } else if (i + 1 == registeredUsers!.length && reply == false) {
      //       try {
      //         firebaseInstance!.addUsers(userInformation);
      //         contractProvider!.registerVoter(id!);
      //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //             backgroundColor: Colors.black,
      //             content: Text(
      //               "Registered Successfully",
      //               style: TextStyle(fontSize: 20, color: Colors.white),
      //             )));
      //         Navigator.pushReplacement(
      //             context, MaterialPageRoute(builder: ((context) => Home())));
      //       } on FirebaseException catch (e) {
      //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //           backgroundColor: Colors.black,
      //           content: Text(
      //             "Something went wrong",
      //             style: TextStyle(color: Colors.white, fontSize: 18),
      //           ),
      //         ));
      //       }
      //     }
      //   }
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => SignUpPageProvider(context: context),
      child: body(),
    );
  }

  Widget body() {
    return Builder(builder: (BuildContext context) {
      signUpPageProvider = context.watch<SignUpPageProvider>();
      Widget? body;
      if (signUpPageProvider!.loading == false) {
        body = SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            caputuredImage(),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Spacer(),
                Expanded(
                  flex: 8,
                  child: SignUpForm(),
                ),
                Spacer()
              ],
            ),
            // CustomButton(
            //     buttonText: "Verify Face",
            //     onPressed: () {
            //       deepFaceApi!
            //           .verifyFace("images/mobile1.jpeg", "images/Mobile2.jpeg");
            //     })
          ],
        ));
      } else if (signUpPageProvider!.loading == true) {
        body = Center(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Processing the registration, Please wait",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: Colors.white,
        body: body,
      );
    });
  }

  Widget _body() {
    return SafeArea(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        caputuredImage(),
        SizedBox(
          height: 30,
        ),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer()
          ],
        ),
        // CustomButton(
        //     buttonText: "Verify Face",
        //     onPressed: () {
        //       deepFaceApi!
        //           .verifyFace("images/mobile1.jpeg", "images/Mobile2.jpeg");
        //     })
      ],
    ));
  }

  Widget caputuredImage() {
    File imageFile = File(widget.imagePath);
    FileImage fileImage = FileImage(imageFile);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: fileImage,
          ),
        ),
      ),
    );
  }

  Widget SignUpForm() {
    return Form(
        key: _formkey,
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.black,
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the Email";
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Your Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.email_outlined),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                cursorColor: Colors.black,
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the Name";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    hintText: "Your Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.person_outlined),
                    )),
              ),
            ),
            const SizedBox(height: 5),
            CustomButton(
                buttonText: "Sign Up",
                onPressed: () {
                  registration();
                }),
            const SizedBox(
              height: 16,
            ),
            AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Home();
                  }));
                })
          ],
        ));
  }
}
