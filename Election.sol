// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ElectionFactory {

    address public _electionManager;
    Election[] public electionConducted;

    event ElectionEvent(address _admin, Election election);

      constructor(){
        _electionManager = msg.sender;
    }

     modifier onlyElectionManager() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns(bool) {
        return msg.sender == _electionManager;
    }
    
    function createElection (string memory _electionName, uint _noOfSeats, uint _electionDurationInMinutes) public onlyElectionManager {
        Election election = new Election(_electionName,_noOfSeats, _electionDurationInMinutes, payable(msg.sender));
        electionConducted.push(election);
        emit ElectionEvent(msg.sender,election);
    }
    
    function getElections() public view returns(Election[] memory _conductedElection) {
        return electionConducted;
    }    
}


contract Election {

    event AddConstituencyEvent(uint _consituencyId, address admin);
    event AddCandidateEvent(address _candidateId, uint _partyId, string _party);
    event AddVoterEvent(address _voterId, uint _consituencyId);
    event CastVoteEvent(string message);
    event ClosedElectionEvent(bool _electionStatus);

    address public admin;
    uint public noOfSeats;
    string public electionName;
    bool electionStatus;
    uint electionDuration;

    struct Voter {
        address voterId;
        string name;
        string email;
        string phoneNo;
        uint consituencyId;
        uint8 age;
        bool voted;
    }
    
    struct Candidate {
        address candidateId;
        string name;
        string email;
        string phoneNo;
        uint consituencyId;
        string party;
    }

    struct Consituency {
        uint consituencyId;
        string name;
        address[] candidates;
        address[] voters;
        mapping(address => uint) votes;
        address winner;
    }

    struct Party{
        uint partyId;
        string name;
        address[] candidates;
        address[] voters;
        mapping(uint => uint) partyVotes;
    }

    address[] public votersList;
    mapping (address => bool) public voterExist;
    mapping (address => Voter) public voterData;
    
    
    address[] public candidateList;
    mapping (address => bool) public candidateExist;
    mapping (address => Candidate) public candidateData;


    uint public countConsituency;
    uint[] public consituencyList;
    mapping (uint => bool) public consituencyExist;
    mapping (uint => Consituency) public consituencyData;

   
    uint[] public partyIdList;
    uint public countParty;
    mapping(uint => bool) public partyExit;
    mapping(uint => Party) public partyData;
    
    constructor( string memory _electionName, uint _noOfSeats, uint _electionDurationInMinutes, address payable _admin) {
        admin = _admin;
        electionName = _electionName;
        noOfSeats = _noOfSeats;
        electionStatus = true;
        electionDuration = block.timestamp +(_electionDurationInMinutes * 60); 
    }

     modifier onlyAdmin {
        require(admin == msg.sender, "Only admin can execute this function!");
        _;
    }

   function addConsituency(uint _consituencyId, string memory _name) public onlyAdmin {
        require(!consituencyExist[_consituencyId], "Consituency already exist");
        require(countConsituency <= noOfSeats,"Sorry Consituency is full");
        consituencyExist[_consituencyId] = true;
        countConsituency = countConsituency + 1;
        consituencyData[_consituencyId].consituencyId = _consituencyId;
        consituencyData[_consituencyId].name = _name;
        consituencyList.push(_consituencyId);
        emit AddConstituencyEvent(_consituencyId, msg.sender);
    }

    function getConsituencyIdList() public view returns(uint[] memory) {
        return consituencyList;
    }
  
    function addCandidate(address _candidateId, string memory  _name, string memory _email, string memory _phoneNo, uint _consituencyId, uint _partyId, string memory _party) public onlyAdmin{
        require(admin != _candidateId, "Admin can't be a candidate");
        require(!candidateExist[_candidateId], "Candidate already exist!");
        require(!partyExit[_partyId],"Party Already Exist");
        candidateList.push(_candidateId);
        candidateExist[_candidateId] = true;
        candidateData[_candidateId].candidateId = _candidateId;
        candidateData[_candidateId].name = _name;
        candidateData[_candidateId].email = _email;
        candidateData[_candidateId].phoneNo = _phoneNo;
        candidateData[_candidateId].consituencyId = _consituencyId;
        candidateData[_candidateId].party = _party; 
        consituencyData[_consituencyId].candidates.push(_candidateId);
        partyData[_partyId].partyId = _partyId;
        countParty = countParty + 1;
        emit AddCandidateEvent(_candidateId,_partyId,_party);
    }

    function getCandidatesIdList() public view returns(address[] memory) {
        return candidateList;
    }

    function getCandidateParty(address _candidateId) public view returns(string memory) {
        return candidateData[_candidateId].party;

    }
    

    function getConsituencyCandidates(uint _consituencyId) public view returns(address[] memory) {
        return consituencyData[_consituencyId].candidates;
    }

     function addVoter(address _voterId, string memory _name, string memory _email, string memory _phoneNo, uint _consituencyId, uint8 _age) public onlyAdmin{
        require(admin != _voterId, "Admin can't be a voter");
        require(!voterExist[_voterId], "Voter already exist!");
        votersList.push(_voterId);
        voterExist[_voterId] = true;
        voterData[_voterId].voterId = _voterId;
        voterData[_voterId].name = _name;
        voterData[_voterId].email = _email;
        voterData[_voterId].phoneNo = _phoneNo;
        voterData[_voterId].consituencyId = _consituencyId;
        voterData[_voterId].age = _age;
        voterData[_voterId].voted = false;
        consituencyData[_consituencyId].voters.push(_voterId);
        emit AddVoterEvent(_voterId,_consituencyId);
    }

    function getVotersIdList() public view returns(address[] memory ) {
        return votersList;
    }
    
    function getConsituencyVoters(uint _consituencyId) public view returns(address[] memory) {
        return consituencyData[_consituencyId].voters;
    }

    function getVoterConsituency() public view returns(uint) {
        return voterData[msg.sender].consituencyId;
    } 

    function castVote(uint _consituencyId, address _candidateId) public returns(bool status) {
        require(electionStatus, "Election must be on/active");
        require(admin != msg.sender, "Admin can't cast a vote");
        require(!voterData[msg.sender].voted, "Voter already casted his vote");
        if(candidateData[_candidateId].consituencyId == _consituencyId) {
            consituencyData[_consituencyId].votes[_candidateId] += 1;
            voterData[msg.sender].voted = true;
            return true;
        }else {
            return false;
        }
    }

    function getVotes(uint _consituencyId, address _candidateId) public view returns(uint) {
        return consituencyData[_consituencyId].votes[_candidateId];
    }

    function closeElection() public onlyAdmin {
        require(block.timestamp > electionDuration, "Election is not completed");
        require(electionStatus, "Election is not active");
        electionStatus = false;
        emit ClosedElectionEvent(electionStatus);
    }
}


