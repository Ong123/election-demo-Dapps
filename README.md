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
*
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
    
    function getCandidatesIdList() public view returns(address[]) {
        return candidateList;
    }
```

    
