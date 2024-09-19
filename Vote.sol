// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedVoting {
    // everybody could vote once
    // only contract owner can create something to vote

    // not everyone can have a ETh wallet or metamask account, so this contract uses a unique fund for everyone, so they can vote.

    // become a publisher, only someone with private api key can become publisher.

    struct voteEvent {
        Topic Topic1;
        Topic Topic2;
        uint256 id;
        bool status;
        string publisherId;
        string publisherName;
    }

    struct Topic {
        string description;
        uint voteCount;
    }

    address public fund;

    // total number of voteEvent, initialized as 0
    uint256 totalVoteEvent;

    // Mapping address of voter, all the registered user will be inserted into this map
    mapping(string => bool) public voters;

    // Mapping to check if user has voted a event or not
    // uint256 = id of event
    // address = adress of voter
    // bool = voted or not
    mapping(uint256 => mapping(string => bool)) public eventVoted;

    // Status of the voteEvent, if it's true, means its open. false = closed
    mapping(uint256 => bool) public voteEventStatus;

    // all the voteEvents
    mapping(uint256 => voteEvent) public voteEvents;

    // all the publisher
    mapping(string => bool) public publishers;

    // creator of voteEvents
    mapping(uint256 => mapping(string => bool)) public voteEventsCreators;

    // owner of smart contract
    address public admin;

    // Emit when the voter is registred
    event VoterRegistered(string indexed voter);

    // Emit when the voter is registred
    event publisherRegistered(string indexed publisher);

    // Emit when vote is Casted
    event VoteCasted(
        address indexed voter,
        uint256 indexed topicThatsBeenVoted
    );
    // Emit when Vote is ended
    event VotingEventEnded();
    // Emit when Vote is started
    event VoteEventStart();
    // Emit when Vote is ended
    event VotingEventStart(voteEvent indexed startedEvent);
    // Emit a Vote Event is created
    event voteEventCreated(uint256 indexed idVoteEventCreated);

    // Modifier for the function that
    // can be casted only by Owner of Contract
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // only publisher can cast the function
    modifier onlyPublisher(string memory publisher) {
        require(publishers[publisher], "Only Publisher can call this function");
        _;
    }

    modifier onlyEventCreator(string memory publisher, uint256 eventId) {
        require(
            voteEventsCreators[eventId][publisher],
            "only Event creator can close the Vote Event"
        );
        _;
    }

    // Modifer for the function
    // that can be only casted by who is registred
    modifier onlyRegistered(string memory voter) {
        // When msg.sender is not in the voters mapping:
        // voters[msg.sender] returns a
        // default-constructed Voter struct. And isRegistered is boolean type
        // voters[msg.sender].isRegistered will thus be false
        require(voters[voter], "Voter is not registered");
        _;
    }

    modifier onlyActive(uint256 eventId) {
        require(voteEventStatus[eventId] == true, "Voting is not active");
        _;
    }

    constructor() {
        admin = msg.sender;
        fund = msg.sender;
        totalVoteEvent = 0;
        voters["9c3acdb0-e215-4262-b5b4-5e90b7dae605"] = true;
        // topic = _topic;
        // votingActive = true;
    }

    function registerUser(string memory voter) external onlyAdmin {
        require(!voters[voter], "Voter is already registered");
        voters[voter] = true;
        emit VoterRegistered(voter);
    }

    function becomePublisher(string memory publisher) external onlyAdmin {
        require(!publishers[publisher], "You are already a publisher");
        publishers[publisher] = true;
        emit publisherRegistered(publisher);
    }

    function startVoting(uint256 eventId) external onlyAdmin {
        require(voteEvents[eventId].status == true, "Voting is already active");
        voteEvents[eventId].status = true;
        emit VoteEventStart();
    }

    function endVoting(
        uint256 eventId,
        string memory publisher
    ) external onlyEventCreator(publisher, eventId) {
        // voteEvents[eventId].Topic1.voteCount
        require(
            voteEvents[eventId].status == false,
            "Voting is already closed"
        );
        voteEvents[eventId].status = false;
        emit VotingEventEnded();
    }

    function castVote(
        uint256 eventId,
        uint256 topic,
        string memory voter
    ) external onlyRegistered(voter) onlyActive(eventId) {
        require(!eventVoted[eventId][voter], "Voter has already voted");
        require(topic == 0 || topic == 1, "Invalid topic choice");

        eventVoted[eventId][voter] = true;

        if (topic == 0) {
            voteEvents[eventId].Topic1.voteCount++;
        } else if (topic == 1) {
            voteEvents[eventId].Topic2.voteCount++;
        }

        emit VoteCasted(msg.sender, topic);
    }

    function getVoteEvents() external view returns (voteEvent[] memory) {
        voteEvent[] memory allVoteEvents = new voteEvent[](totalVoteEvent);

        for (uint i = 0; i < totalVoteEvent; i++) {
            allVoteEvents[i] = voteEvents[i];
        }
        return allVoteEvents;
    }

    function getResultForTopicOne(
        uint256 eventId
    ) external view returns (uint256) {
        return voteEvents[eventId].Topic1.voteCount;
    }

    function getResultForTopicTwo(
        uint256 eventId
    ) external view returns (uint256) {
        return voteEvents[eventId].Topic2.voteCount;
    }

    function createVoteEvent(
        string memory description1,
        string memory description2,
        string memory publisher,
        string memory publisherName
    ) external onlyPublisher(publisher) {
        voteEvents[totalVoteEvent] = voteEvent({
            Topic1: Topic(description1, 0),
            Topic2: Topic(description2, 0),
            id: totalVoteEvent,
            status: true,
            publisherId: publisher,
            publisherName: publisherName
        });
        voteEventStatus[totalVoteEvent] = true;
        voteEventsCreators[totalVoteEvent][publisher] = true;
        emit voteEventCreated(totalVoteEvent);

        totalVoteEvent++;
    }
}
