import 'package:app/model/contract_provider.dart';
import 'package:app/model/user.dart';
import 'package:app/screen/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      String? firstTopic;
      String? secondTopic;
      String? firstTopicCount;
      int? firstTopicCountInteger;
      String? secondTopicCount;
      int? secondTopicCountInteger;
      if (contractProvider!.loading == true) {
        _body = Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color?>(Colors.black),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        );
      } else {
        firstTopic = contractProvider!.Events[0][0];
        secondTopic = contractProvider!.Events[1][0];
        firstTopicCount = contractProvider!.Events[0][1].toString();
        BigInt firstCount = contractProvider!.Events[0][1];
        firstTopicCountInteger = firstCount.toInt();
        BigInt secondCount = contractProvider!.Events[1][1];
        secondTopicCountInteger = secondCount.toInt();
        secondTopicCount = contractProvider!.Events[1][1].toString();
        _body = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.white30),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
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
                      const SizedBox(
                        height: 10,
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
                        height: 5,
                      ),
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
                      contractProvider!.castVote(0, 0, widget.user.id);
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
                      contractProvider!.castVote(0, 1, widget.user.id);
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
      return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
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
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
            elevation: 0,
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
}
