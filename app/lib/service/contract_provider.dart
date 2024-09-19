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
    voteEvents(contractAddress);
  }
  BuildContext context;
  // http client for sending request
  Client httpclient;
  // Web3 client for Ethereum interaction
  Web3Client ethClient;
  // List for Vote Events fetched from blockchain
  List<dynamic> Events = [];
  bool loading = false;
  // smart contract address
  // String contractAddress = "0xf4F6b8B66045ee89Cfd56a8f45D1Cb44DC9d5AC8";
  String contractAddress = "0xb5cc77189c4f4dcc5Bf704123AE4Bf90FDD471a5";
  // Private Key for transaction
  final String privateKey =
      "5ce525baae5e70f19e836d5e969edc94ffc39c8e977f245cc53a5ddbc31f651b";

  void pageLoading() {
    loading = true;
    notifyListeners();
  }

  void pageUnloading() {
    loading = false;
    notifyListeners();
  }

  // Method to get the deployed smart contract
  Future<DeployedContract> getContract(String contractAddress) async {
    // Load the ABI file from assets
    String abiFile = await rootBundle.loadString("assets/voting_abi_def.json");

    // Create a deployed Contract instance
    final contract = DeployedContract(ContractAbi.fromJson(abiFile, "Voting"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  // Verify if a given ID is a publisher or not
  Future<bool> verifyPublisher(String publisherId) async {
    // Get the contract
    final contract = await getContract(contractAddress);
    // user the function from the contract, this is a "GET" function
    final function = contract.function("publishers");
    // use BigInt in interaction with contract
    final result = await ethClient
        .call(contract: contract, function: function, params: [publisherId]);
    print(result[0]);
    return result[0];
  }

  // Method to fetch a specific Vote events
  Future<List<dynamic>> voteEvents(String contractAddress) async {
    loading = true;
    // Get the contract
    final contract = await getContract(contractAddress);
    // user the function from the contract, this is a "GET" function
    final function = contract.function("getVoteEvents");
    // use BigInt in interaction with contract

    // call the contract function and store the result
    final result = await ethClient
        .call(contract: contract, function: function, params: []);
    // assign the result to the Events List
    Events = result;
    loading = false;
    notifyListeners();
    print("The result of events: ${result}");
    print(result[0][0]); // [[Chinese Resturant, 0], [Italian Resturant, 0], 0]
    print(result[0][0][0]); // [Chinese Resturant, 0]
    print(result[0][0][0][1]); // 0
    print(result[0][1]); // [[Chinese Resturant, 0], [Italian Resturant, 0], 0]
    print(result[0][1][0]); // [Chinese Resturant, 0]

    print(result[0][1][0][1]); // [Chinese Resturant, 0]

    if (result[0][0] is String) {
      print("It's a String");
    }
    return result;
  }

  // register a voter
  Future<void> registerVoter(String voterId) async {
    pageLoading();
    // get contract by Address
    final contract = await getContract(contractAddress);
    // get the specific function of contract
    final function = contract.function("registerVoter");
    // create credentials from private key
    final credentials = EthPrivateKey.fromHex(privateKey);
    print("registerVoter is executing!");
    try {
      // send the transaction to register voter
      final answer = await ethClient.sendTransaction(
          credentials,
          chainId: 11155111,
          Transaction.callContract(
              contract: contract, function: function, parameters: [voterId]));
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<String> becomePublisher(String userId) async {
    pageLoading();
    // get contract by Address
    final contract = await getContract(contractAddress);
    // get the specific function of contract
    final function = contract.function("becomePublisher");
    // create credentials from private key
    final credentials = EthPrivateKey.fromHex(privateKey);
    print("Become Publisher is executing!");
    try {
      final publisherRegisteredEvent = contract.event("publisherRegistered");

      // send the transaction to become a publisher
      final answer = await ethClient.sendTransaction(
          credentials,
          chainId: 11155111,
          Transaction.callContract(
              contract: contract, function: function, parameters: [userId]));

      final subscription = ethClient
          .events(FilterOptions.events(
              contract: contract, event: publisherRegisteredEvent))
          .take(100)
          .listen((event) {
        print("The user become a publisher!");
        pageUnloading();
      });
      return answer;
    } on Exception catch (e) {
      pageUnloading();
      print(e);
    }
    return "null";
  }

  Future<String> createAVoteEvent(String firstDescription,
      String secondDescription, String publisherId) async {
    // get contract by Address
    final contract = await getContract(contractAddress);
    // get the specific function of Contract
    final function = contract.function("createVoteEvent");
    // create credentials from private key
    final credentials = EthPrivateKey.fromHex(privateKey);
    try {
      print("create A vote Event!");
      final voteCreatedEvent = contract.event("voteEventCreated");
      final answer = await ethClient.sendTransaction(
          credentials, // Use credentials (private key) for signing the transaction
          chainId:
              11155111, // Chain ID of the Ethereum network， Sepolia TestNetwork

          // / Creates a transaction to call a smart contract method
          Transaction.callContract(
              contract: contract,
              function: function,
              parameters: [firstDescription, secondDescription, publisherId]));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Creating a VoteEvent, it may take some time!",
            style: TextStyle(fontSize: 20, color: Colors.white),
          )));
      // subscribe to events emmitted by the contract, specifically the "VoteCasted" event.
      // This listens for up to 100 VoteCasted Events and performs an action each time the event is triggered
      final subscription = ethClient
          .events(FilterOptions.events(
              contract: contract,
              event: voteCreatedEvent)) // listen to voteCastedEvent
          .take(100)
          .listen((event) {
        // when a cote casted event occurs, update the UI by calling voteEvents function
        // voteEvents will fetch the newiest event, in this way it will update the Events List
        voteEvents(contractAddress);
      });

      return answer;
    } on Exception catch (e) {
      print(e.toString());
      print(e);
      if (e.toString() ==
          'RPCError: got code 3 with msg "execution reverted: Only Publisher can call this function".') {
        showDialog(
            context: context,
            builder: (BuildContext _context) {
              return AlertDialog(
                title: Text("Warning"),
                content: Text(
                    "You are not a Publisher! Become a Publisher then you care create Vote Event"),
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

  // cast a vote for a specific Voter Event
  // voterID: the ID of user that's going to vote
  Future<String> castVote(int eventId, int topic, String voterId) async {
    // get contract by Address
    final contract = await getContract(contractAddress);
    // get the specific function of Contract
    final function = contract.function("castVote");
    // specific Event that user going to vote
    final eventBigInt = BigInt.from(eventId);
    // specific topic user going to vote, there will be 2 topic in one event, so it's a integer
    final topicbigInt = BigInt.from(topic);
    // create credentials from private key
    final credentials = EthPrivateKey.fromHex(privateKey);
    // The address of the creadentials
    final ownAddress = credentials.address;

    print("Invoking castVote function");
    print(ownAddress);
    print(credentials);
    print(await ethClient.getBalance(ownAddress));
    print(await ethClient.getChainId());
    try {
      // Get the "VoteCasted" event from the smart contract.
      // This event will be triggered after a successful vote and can be captured in the front-end.
      final voteCastedEvent = contract.event("VoteCasted");

      // Send a transaction to the Ethereum network to cast a vote.
      // The transaction will invoke the 'castVote' function on the smart contract.
      final answer = await ethClient.sendTransaction(
          credentials, // Use credentials (private key) for signing the transaction
          chainId:
              11155111, // Chain ID of the Ethereum network， Sepolia TestNetwork

          // / Creates a transaction to call a smart contract method
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
      // subscribe to events emmitted by the contract, specifically the "VoteCasted" event.
      // This listens for up to 100 VoteCasted Events and performs an action each time the event is triggered
      final subscription = ethClient
          .events(FilterOptions.events(
              contract: contract,
              event: voteCastedEvent)) // listen to voteCastedEvent
          .take(100)
          .listen((event) {
        // when a cote casted event occurs, update the UI by calling voteEvents function
        // voteEvents will fetch the newiest event, in this way it will update the Events List
        voteEvents(contractAddress);
        notifyListeners();
      });

      return answer;
    } on Exception catch (e) {
      print(e.toString());
      print(e);
      // if the error indicates that the voter has already voted, show the Dialog to inform user the already voted
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
