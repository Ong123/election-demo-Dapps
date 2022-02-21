# Election-demo-DApps

## Introduction
Election demo DApps has been developed for only Education & Learning purpose, not for any production & All the features are based on Indian Election Process. In the Indian election process, every state is being divided into different constituencies, each constituency will have one representative, elected by the voters of a constituency to a Legislative Assembly is called MLA(Member of Legislative Assembly).

There are two different contracts, the first one is for ElectionFactory & the second one is for Election. All the elections will be created from the ElectionFactory contract. 

This project has been designed using a Factory design pattern.

### Features:-
* Create n number of election.
* Store created elections.
* Display all elections, that had been created.
* Add constituencies.
* Get all constituencies.
* Add Candidates.
* Get Candidates.
* 


### ElectionFactory:-

* createElection() will create new election, push it to electionConducted Array & emit the ElectionEvent event.
```solidity 
 function createElection (uint _durationInMinutes, string _electionName) public {
        address newElection = new Election(_durationInMinutes, msg.sender, _electionName);
        electionConducted.push(newElection);
        emit ElectionEvent(msg.sender, newElection);
    }
```
 * getElection()- return electionConducted array of address. 
 
 ```solidity  
  function getElections() public view returns(address[] _conductedElection) {
          return electionConducted;
      }
 ```
### Election

* addConstituency()- Add constituency, check constituency already exist or not if exist then throw Error, make constituencyExist true, add constituency, push it _constituencyID to consituencyList mapping.

```solidity
function addConsituency(uint _consituencyId, string _name) public onlyAdmin {
        require(!consituencyExist[_consituencyId], "Consituency already exist");
        consituencyExist[_consituencyId] = true; 
        consituencyData[_consituencyId].consituencyId = _consituencyId;
        consituencyData[_consituencyId].name = _name;
        consituencyList.push(_consituencyId);
    }
```
* getConsituency()- return list of constituencyList
```solidity
function getConsituencyIdList() public view returns(uint[]) {
        return consituencyList;
    }
```
* addCandidate()- 
  * check if admin registering himself as candidate, if yes throw "Admin can't be a candidate" Error else 
  * check if candidate is registred or not, if yes throw "Candidate already exist" Error else
  * add candidate in candidateList.
  * add candidate to its consituency  
```solidity
function addCandidate(address _candidateId, string _name, string _email, string _phoneNo, uint _consituencyId, string _party) public onlyAdmin{
        // check if admin is registering himself as candidate
        require(admin != _candidateId, "Admin can't be a candidate");
        
        // It will check if candidate is registered or not
        require(!candidateExist[_candidateId], "Candidate already exist!");
        // add candidate in candidateList
        candidateList.push(_candidateId);
            
        candidateExist[_candidateId] = true;
        candidateData[_candidateId].candidateId = _candidateId;
        candidateData[_candidateId].name = _name;
        candidateData[_candidateId].email = _email;
        candidateData[_candidateId].phoneNo = _phoneNo;
        candidateData[_candidateId].consituencyId = _consituencyId;
        candidateData[_candidateId].party = _party;
        // add candidate to its consituency
        consituencyData[_consituencyId].candidates.push(_candidateId);
    }
  ```
  * getCandidateIdList()- return candidateList
  ```-solidity
    
    function getCandidatesIdList() public view returns(address[]) {
        return candidateList;
    }
```
*  getCandidateIdList()- return candidateList.

```solidity
  function getCandidatesIdList() public view returns(address[]) {
         return candidateList;
     }
```

* getConsituencyCandidates()- return candidates.

```solidity
  function getConsituencyCandidates(uint _consituencyId) public view returns(address[]) {
        return consituencyData[_consituencyId].candidates;
    }

```
* getCandidateConsituency() - return candidate consituencyId.
```solidity
   function getCandidateConsituency () public view returns(uint) {
        return candidateData[msg.sender].consituencyId;
    }
```
*

```solidity
 function addVoter(address _voterId, string _name, string _email,string _phoneNo, uint _consituencyId, uint8 _age) 
         public onlyAdmin{
         // check if admin is registering himself
         require(admin != _voterId, "Admin can't be a voter");
         // It will check if voter is registered or not
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

         // add voter to its consituency
         consituencyData[_consituencyId].voters.push(_voterId);
     }

```
*
```solidity
  function getVotersIdList() public view returns(address[]) {
        return votersList;
    }
```
*
```solidity
function getConsituencyVoters(uint _consituencyId) public view returns(address[]) {
        return consituencyData[_consituencyId].voters;
    }
```
*
```solidity
function getVoterConsituency() public view returns(uint) {
        return voterData[msg.sender].consituencyId;
    }
```
*
```solidity

function castVote(uint _consituencyId, address _candidateId) public returns(bool status) {
         //election must be active
        require(electionStatus, "Election must be on/active");

        // admin can't cast a vote
        require(admin != msg.sender, "Admin can't cast a vote");

        // check if voter has voted or not
        require(!voterData[msg.sender].voted, "Voter already casted his vote");
        
        // check if candidate is of respective consituency
        if(candidateData[_candidateId].consituencyId == _consituencyId) {
            consituencyData[_consituencyId].votes[_candidateId] += 1;
            voterData[msg.sender].voted = true;
            return true;
        }else {
            return false;
        }
    }
```
*
```solidity
function getVotes(uint _consituencyId, address _candidateId) public view returns(uint) {
        return consituencyData[_consituencyId].votes[_candidateId];
    }

```
*
```solidity
function closeElection() public onlyAdmin {
        require(now > electionDuration, "Election is not completed");
        require(electionStatus, "Election is not active");
        electionStatus = false;
    }

```








    
