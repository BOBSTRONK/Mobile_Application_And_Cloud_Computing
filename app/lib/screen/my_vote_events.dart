import 'package:app/model/user.dart';
import 'package:app/screen/log_in.dart';
import 'package:app/service/contract_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class MyVoteEvents extends StatefulWidget {
  const MyVoteEvents({super.key, required this.user});
  final User user;

  @override
  State<MyVoteEvents> createState() => _MyVoteEventsState();
}

class _MyVoteEventsState extends State<MyVoteEvents> {
  ContractProvider? contractProvider;
  late Client httpclient;
  late Web3Client ethClient;
  final String rpcUrl =
      "https://eth-sepolia.g.alchemy.com/v2/1WyDdrv-NGBT-ZafMq8xdadQTPiwFHK6";
  final String wsUrl =
      "wss://eth-sepolia.g.alchemy.com/v2/1WyDdrv-NGBT-ZafMq8xdadQTPiwFHK6";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContractProvider>(
      create: (context) => ContractProvider(
          httpclient: httpclient, ethClient: ethClient, context: context),
      child: _build(context),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    httpclient = Client();
    ethClient = Web3Client(rpcUrl, httpclient);
  }

  Widget _build(BuildContext ocntext) {
    return Builder(builder: (BuildContext context) {
      contractProvider = context.watch<ContractProvider>();
      Widget? _body;
      if (contractProvider!.loading == true) {
        _body = Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
        );
      } else {
        _body = Column(
          children: [
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
                      'Vote Event',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 24),
                    ),
                    Text(
                      'That has been created by you:',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: contractProvider!.Events[0].length,
                    itemBuilder: (_, index) {
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
                      String publisherId =
                          contractProvider!.Events[0][index][4];
                      String publisherName =
                          contractProvider!.Events[0][index][5];
                      if (publisherId == widget.user.id) {
                        return VoteEventTile(
                            firstTopicCountInteger,
                            firstTopic,
                            firstTopicCount,
                            secondTopicCountInteger,
                            secondTopic,
                            secondTopicCount,
                            eventId,
                            publisherId,
                            publisherName,
                            eventStatus);
                      }
                    }))
          ],
        );
      }
      return Scaffold(
        body: _body,
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          leading: GestureDetector(
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (BuildContext build) {
                return VotingPage(user: widget.user);
              }));
            },
          ),
          title: const Text(
            'My Vote Event',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
      );
    });
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
      String publisherName,
      bool eventStatus) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 400,
            height: 320,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40), color: Colors.white30),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  eventStatus == true
                      ? Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext _context) {
                                      return AlertDialog(
                                        title: Text("Warning"),
                                        content: Text(
                                            "You are trying to Close the Vote Event"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(_context).pop();
                                              },
                                              child: Text("Cancel")),
                                          TextButton(
                                              onPressed: () {
                                                contractProvider!.endVoting(
                                                    eventID, publisherID);
                                                Navigator.of(_context).pop();
                                              },
                                              child: Text("Close it")),
                                        ],
                                      );
                                    });
                              },
                              child: Icon(Icons.assignment_turned_in_outlined)),
                        )
                      : SizedBox(),
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
                          SizedBox(
                            height: 5,
                          ),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                eventStatus == true
                                    ? "Event is currently: Open"
                                    : "Event is currently: Closed",
                                style: TextStyle(
                                    color: Colors.red,
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
                onTap: () {},
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
                onTap: () {},
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
