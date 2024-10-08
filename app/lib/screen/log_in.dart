import 'package:app/model/user.dart';
import 'package:app/screen/becomePublisher.dart';
import 'package:app/screen/home.dart';
import 'package:app/screen/my_vote_events.dart';
import 'package:app/service/contract_provider.dart';
import 'package:app/service/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:m7_livelyness_detection/index.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key, required this.user});
  final User user;

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  ContractProvider? contractProvider;
  late Client httpclient;
  late Web3Client ethClient;

  String? firstTopic, secondTopic;
  TextEditingController firstTopicController = new TextEditingController();
  TextEditingController secondTopicController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool? itsPublisherOrNot;
  final String myAddress = "0xBB0b117ed33C4e059e15C277E8FDCA8A9ac57380";
  // 0x20ffb7d5d7fcf402203e538f04fec7d71fa703ec
  // 85d2242ae1b7759934d4b0d4f0d62d666cf7d73e21dbd09d73c7de266b72a25a

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

  void createAVoteEvent() {
    if (_formKey.currentState!.validate()) {
      firstTopic = firstTopicController.text;
      secondTopic = secondTopicController.text;
      contractProvider!.createAVoteEvent(
          firstTopic!, secondTopic!, widget.user.id, widget.user.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider<ContractProvider>(
      create: (context) => ContractProvider(
          httpclient: httpclient, ethClient: ethClient, context: context),
      child: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      contractProvider = context.watch<ContractProvider>();
      Widget? _body;

      if (contractProvider!.loading == true) {
        _body = Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Casting the vote!",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "It may take some time!",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "DO NOT leave the page!",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
        );
      } else {
        print("This is Vote Event of contract ${contractProvider!.Events}");
        _body = Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 145,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset('assets/images/vote.jpeg'),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi Guys!',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 24),
                    ),
                    Text(
                      'Welcome To Voting Poll!',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: contractProvider!.Events[0].length,
                  itemBuilder: (_, index) {
                    // one example of voteEvents  [[Chinese Resturant, 3], [Italian Resturant, 2], 0]
                    String firstTopic =
                        contractProvider!.Events[0][index][0][0];
                    String secondTopic =
                        contractProvider!.Events[0][index][1][0];
                    String firstTopicCount =
                        contractProvider!.Events[0][index][0][1].toString();
                    BigInt firstCount =
                        contractProvider!.Events[0][index][0][1];
                    int firstTopicCountInteger = firstCount.toInt();
                    BigInt secondCount =
                        contractProvider!.Events[0][index][1][1];
                    int secondTopicCountInteger = secondCount.toInt();
                    String secondTopicCount =
                        contractProvider!.Events[0][index][1][1].toString();
                    BigInt eventId_bigInt =
                        contractProvider!.Events[0][index][2];
                    int eventId = eventId_bigInt.toInt();
                    bool eventStatus = contractProvider!.Events[0][index][3];
                    String publisherId = contractProvider!.Events[0][index][4];
                    String publisherName =
                        contractProvider!.Events[0][index][5];
                    print("eventID: ${eventId}");
                    print("the first topic here: ${firstTopic}");
                    if (eventStatus == true) {
                      return VoteEventTile(
                          firstTopicCountInteger,
                          firstTopic,
                          firstTopicCount,
                          secondTopicCountInteger,
                          secondTopic,
                          secondTopicCount,
                          eventId,
                          publisherId,
                          publisherName);
                    }
                  }),
            )
          ],
        );
      }
      return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                DrawerHeader(
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "B-Voting Application",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/blockchainIllustration.png'),
                          fit: BoxFit.cover)),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('User Information'),
                  onTap: () async {
                    itsPublisherOrNot =
                        await contractProvider!.verifyPublisher(widget.user.id);
                    if (itsPublisherOrNot == true) {
                      showDialog(
                          context: context,
                          builder: (BuildContext _context) {
                            return AlertDialog(
                              title: Text("Create a Vote Event"),
                              content: Container(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "User Name: ${widget.user.name}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Email: ${widget.user.email}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(_context).pop();
                                    },
                                    child: Text("Ok")),
                              ],
                            );
                          });
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext _context) {
                            return AlertDialog(
                              title: Text("Warning"),
                              content: Container(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "You are not a Publisher, become publisher first, Then you can publish the vote Event",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(_context).pop();
                                    },
                                    child: Text("Understood")),
                              ],
                            );
                          });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.supervisor_account),
                  title: const Text('Become Publisher'),
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (BuildContext build) {
                      return BecomePublisherPage(user: widget.user);
                    }));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.supervisor_account),
                  title: const Text('My Vote Event'),
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (BuildContext build) {
                      return MyVoteEvents(user: widget.user);
                    }));
                  },
                ),
                Divider(
                  height: 10,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('LogOut'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext _context) {
                          return AlertDialog(
                            title: Text("Warning"),
                            content: Text(
                                "You are trying to Log Out, you will be direct to the Home Page"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(_context).pop();
                                  },
                                  child: Text("Reamin here")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) => Home())));
                                  },
                                  child: Text("Log out")),
                            ],
                          );
                        });
                  },
                )
              ],
            ),
          ),
          appBar: AppBar(
            // leading: GestureDetector(
            //   onTap: () {
            // },
            //   child: Icon(
            //     Icons.arrow_back,
            //     color: Colors.white,
            //   ),
            // ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.black,
            elevation: 0,
            actions: [
              GestureDetector(
                child: Icon(Icons.add),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext _context) {
                        return createVoteEventDialog(_context);
                      });
                },
              )
            ],
            title: const Text(
              "Voting",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.black,
          body: _body);
    });
  }

  Widget createVoteEventDialog(BuildContext _context) {
    return AlertDialog(
      title: Text("Create a vote event"),
      content: Container(
        padding: EdgeInsets.all(5),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Description for First Event",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                cursorColor: Colors.black,
                controller: firstTopicController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please A valid description";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: "First event",
                  hintStyle: TextStyle(fontSize: 15),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.description),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Description for Second Event",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                cursorColor: Colors.black,
                controller: secondTopicController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please A valid description";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: "Second event",
                  hintStyle: TextStyle(fontSize: 15),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.description),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              firstTopicController.clear();
              secondTopicController.clear();
              Navigator.of(_context).pop();
            },
            child: Text("Cancel")),
        TextButton(
            onPressed: () {
              createAVoteEvent();
              firstTopicController.clear();
              secondTopicController.clear();
              Navigator.of(_context).pop();
            },
            child: Text("Create")),
      ],
    );
  }

  Widget VoteEventTile(
      int firstTopicCountInteger,
      String firstTopic,
      String firstTopicCount,
      int secondTopicCountInteger,
      String secondTopic,
      String secondTopicCount,
      int eventID,
      String publisherID,
      String publisherName) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 400,
            height: 260,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40), color: Colors.white30),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 50,
                    animation: true,
                    lineHeight: 60.0,
                    animationDuration: 1000,
                    percent: firstTopicCountInteger / 10,
                    center: Text(
                      firstTopic!,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                    barRadius: const Radius.circular(20),
                    progressColor: Colors.greenAccent,
                    backgroundColor: Colors.white30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 50,
                    animation: true,
                    lineHeight: 60.0,
                    animationDuration: 1000,
                    percent: secondTopicCountInteger / 10,
                    center: Text(
                      secondTopic!,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                    barRadius: const Radius.circular(20),
                    progressColor: Colors.indigo,
                    backgroundColor: Colors.white30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Publisher: ${publisherName}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Publisher's ID: ${publisherID}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext _context) {
                        return AlertDialog(
                          title: Text("Info"),
                          content: Text(
                              'You are voting "${firstTopic}", Are you sure?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(_context).pop();
                                },
                                child: Text("No")),
                            TextButton(
                                onPressed: () {
                                  contractProvider!
                                      .castVote(eventID, 0, widget.user.id);
                                  Navigator.of(_context).pop();
                                },
                                child: Text("Yes, I am sure")),
                          ],
                        );
                      });
                },
                child: Container(
                  width: 180,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.indigo),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          firstTopic,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          // count from block chain
                          firstTopicCount,
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext _context) {
                        return AlertDialog(
                          title: Text("Info"),
                          content: Text(
                              'You are voting "${secondTopic}", Are you sure?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(_context).pop();
                                },
                                child: Text("No")),
                            TextButton(
                                onPressed: () {
                                  contractProvider!
                                      .castVote(eventID, 1, widget.user.id);
                                  Navigator.of(_context).pop();
                                },
                                child: Text("Yes, I am sure")),
                          ],
                        );
                      });
                },
                child: Container(
                  width: 180,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.indigo),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          secondTopic,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          // count from block chain
                          secondTopicCount,
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
