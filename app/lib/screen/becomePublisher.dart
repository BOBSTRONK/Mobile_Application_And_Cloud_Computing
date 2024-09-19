import 'package:app/components/components.dart';
import 'package:app/model/user.dart';
import 'package:app/screen/log_in.dart';
import 'package:app/service/contract_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class BecomePublisherPage extends StatefulWidget {
  const BecomePublisherPage({super.key, required this.user});
  final User user;

  @override
  State<BecomePublisherPage> createState() => _BecomePublisherPageState();
}

class _BecomePublisherPageState extends State<BecomePublisherPage> {
  final _formkey = GlobalKey<FormState>();
  String? cdKey;
  Future<bool>? itsPublisherOrNot;
  bool? publisherOrNot;
  TextEditingController cdKeyController = new TextEditingController();
  final String myAddress = "0xBB0b117ed33C4e059e15C277E8FDCA8A9ac57380";
  ContractProvider? contractProvider;
  late Client httpclient;
  late Web3Client ethClient;
  final String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/1WyDdrv-NGBT-ZafMq8xdadQTPiwFHK6";
  final String wsUrl =
      "wss://eth-sepolia.g.alchemy.com/v2/1WyDdrv-NGBT-ZafMq8xdadQTPiwFHK6";

  @override
  void initState() {
    // TODO: implement initState
    httpclient = Client();
    ethClient = Web3Client(rpcUrl, httpclient);
  }

  Future<void> becomeAPublisher() async {
    if (_formkey.currentState!.validate()) {
      cdKey = cdKeyController.text;
      if (cdKey == "1111") {
        await contractProvider!.becomePublisher(widget.user.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Processing your data to become a Publisher! It may take some time!",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext _context) {
              return AlertDialog(
                title: Text("Wrong CD key"),
                content: Text("Please Insert the right CD key"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(_context).pop();
                      },
                      child: Text("Got it")),
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider(
      create: (BuildContext context) => ContractProvider(
          httpclient: httpclient, ethClient: ethClient, context: context),
      child: _build(context),
    );
  }

  @override
  Widget _build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      contractProvider = context.watch<ContractProvider>();
      print(widget.user.id);
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext build) {
                return VotingPage(user: widget.user);
              }));
            },
          ),
        ),
        body: FutureBuilder(
            future: contractProvider!.verifyPublisher(widget.user.id),
            builder: (context, AsyncSnapshot _snapshot) {
              if (_snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (_snapshot.hasData) {
                publisherOrNot = _snapshot.data;
                if (contractProvider!.loading == true) {
                  return Center(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Processing the data to become a Publisher, please Wait and do not leave this page!"),
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (publisherOrNot == true &&
                    contractProvider!.loading == false) {
                  return Center(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "You are already a Publisher!",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                } else if (publisherOrNot == false &&
                    contractProvider!.loading == false) {
                  return Padding(
                    padding: EdgeInsets.all(6),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: RoundedCornerImage(
                            asset:
                                'assets/images/ActiveMinds_VoteEarlyDay_Banner_1200x535_V1.webp',
                            scale: 1.25,
                            imageOffset: Offset(0, 120),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: CurvedCornerContainer(
                            child: DescriptionContent(
                              productTitle: 'Become a Publisher',
                              brand: 'Why?',
                              description:
                                  'By becoming a publisher, you can Publish Vote event without need of A wallet or Ethereum, You can use our fund!',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Form(
                                    key: _formkey,
                                    child: TextFormField(
                                      cursorColor: Colors.black,
                                      controller: cdKeyController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter the CD key";
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        hintText: "CD Key",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Icon(Icons.key_sharp),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomButton(
                                    width: 400,
                                    buttonText: "Become a publisher",
                                    onPressed: () {
                                      becomeAPublisher();
                                    },
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                  );
                }
              }
              return Center(
                child: Container(
                    alignment: Alignment.center,
                    child: Text("Something went wrong")),
              );
            }),
      );
    });
  }
}
