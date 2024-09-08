import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:m7_livelyness_detection/index.dart';
import 'package:web3dart/web3dart.dart';

class ContractProvider extends ChangeNotifier {
  ContractProvider(
      {required this.httpclient,
      required this.ethClient,
      required this.context}) {
    voteEvents(0, contractAddress);
  }
  BuildContext context;
  Client httpclient;
  Web3Client ethClient;
  List<dynamic> Events = [];
  bool loading = false;
  String contractAddress = "0xf4F6b8B66045ee89Cfd56a8f45D1Cb44DC9d5AC8";
  final String privateKey =
      "5ce525baae5e70f19e836d5e969edc94ffc39c8e977f245cc53a5ddbc31f651b";

  Future<DeployedContract> getContract(String contractAddress) async {
    String abiFile = await rootBundle.loadString("assets/voting_abi.json");

    final contract = DeployedContract(ContractAbi.fromJson(abiFile, "Voting"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> voteEvents(int eventId, String contractAddress) async {
    loading = true;
    final contract = await getContract(contractAddress);
    final function = contract.function("voteEvents");
    final eventBigInt = BigInt.from(eventId);

    final result = await ethClient
        .call(contract: contract, function: function, params: [eventBigInt]);
    Events = result;
    loading = false;
    notifyListeners();
    print(result);
    print(result[0][0]);
    if (result[0][0] is String) {
      print("It's a String");
    }
    return result;
  }

  Future<void> registerVoter(String voterId) async {
    final contract = await getContract(contractAddress);
    final function = contract.function("registerVoter");
    final credentials = EthPrivateKey.fromHex(privateKey);
    print("registerVoter is executing!");
    try {
      final answer = await ethClient.sendTransaction(
          credentials,
          chainId: 11155111,
          Transaction.callContract(
              contract: contract, function: function, parameters: [voterId]));
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<String> castVote(int eventId, int topic, String voterId) async {
    final contract = await getContract(contractAddress);
    final function = contract.function("castVote");
    final eventBigInt = BigInt.from(eventId);
    final topicbigInt = BigInt.from(topic);
    final credentials = EthPrivateKey.fromHex(privateKey);
    final ownAddress = credentials.address;

    print("Invoking castVote function");
    print(ownAddress);
    print(credentials);
    print(await ethClient.getBalance(ownAddress));
    print(await ethClient.getChainId());
    try {
      final voteCastedEvent = contract.event("VoteCasted");
      final answer = await ethClient.sendTransaction(
          credentials,
          chainId: 11155111,
          Transaction.callContract(
              contract: contract,
              function: function,
              parameters: [eventBigInt, topicbigInt, voterId]));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Processing your vote, it may take some time!",
            style: TextStyle(fontSize: 20, color: Colors.white),
          )));
      final subscription = ethClient
          .events(
              FilterOptions.events(contract: contract, event: voteCastedEvent))
          .take(100)
          .listen((event) {
        voteEvents(eventId, contractAddress);
        notifyListeners();
      });

      return answer;
    } on Exception catch (e) {
      print(e.toString());
      print(e);
      if (e.toString() ==
          'RPCError: got code 3 with msg "execution reverted: Voter has already voted".') {
        showDialog(
            context: context,
            builder: (BuildContext _context) {
              return AlertDialog(
                title: Text("Warning"),
                content: Text("You have already voted!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(_context).pop();
                      },
                      child: Text("OK"))
                ],
              );
            });
      }
      return "null";
    }
  }
}
