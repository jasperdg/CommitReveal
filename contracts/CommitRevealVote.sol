pragma solidity ^0.4.24;

import "./lib/Decoder.sol";

contract CommitRevealVote {
  using Decoder for Decoder;
  
  struct Commit {
    bytes32 secret;
    bool voted;
    bool revealed;
  }
  
  struct User {
    uint tokens;
    uint lockedTokens;
    mapping(uint => Commit) userCommits;
  }
  
  struct Vote {
    string name;
    // Vote options could easily be dynamic implementing arrays
    bytes32[] options;
    uint[] votes;
    uint commitEnds;
    uint revealEnds;
    bool ended;
  }
  
  mapping (address => User) userBalances;
  mapping (uint => Vote) votes;
  uint[] votesArr;
  
  constructor() public {
      userBalances[address(0x7E23ceCe666fc9C96B3afd1D1a9886b6D6B7e621)] = User(100, 0);
      userBalances[address(0x7f88254273Ea3c092c9bA0e147753331a641E9aA)] = User(100, 0);
  }

  // Example: "EveryDapp", ["0x00", "0x01"], 2043328814, 2123328814
  function addVote(
    string _name, 
    bytes32[] _options,
    uint _commitEnds,
    uint _revealEnds
  ) public {
    // require(_commitEnds > now + 60 * 60 * 24, "commit time should atleast be one day from now"); // Atleast have the commit 1 day from now
    // require(_commitEnds > now + 60 * 60 * 48, "reveal time should atleast be one day after commit"); // Atleast have 1 day to reveal after that

    votes[votesArr.length] = Vote(
      _name, 
      new bytes32[](0), 
      new uint[](0), 
      _commitEnds, 
      _revealEnds, 
      false
    );
    
    for(uint i = 0; i < _options.length; i++) {
      votes[votesArr.length].options.push(_options[i]);
      votes[votesArr.length].votes.push(0);
    }
    
    votesArr.push(votesArr.length);
  }
  
  // Example: 0, 0x63187ec60a67cd31ea7056a075f212643363da65bc07cbae5615aa8f06ae99e9
  function commit(
    uint _voteId, 
    bytes32 _commitSecret
  ) public {
    // require(votes[_voteId].commitEnds > now, "Commit stage is done");
    require(!userBalances[msg.sender].userCommits[_voteId].voted, "User has already participated in this vote");
    userBalances[msg.sender].userCommits[_voteId] = Commit(_commitSecret, true, false);
    userBalances[msg.sender].userCommits[_voteId].voted = true;
  }
  
  
  // Example: 0, 0x010000000000000000000000000000000000000000000000000000000000000014
  function reveal(
    uint _voteId,
    bytes _vote
  ) public {
    require(votes[_voteId].commitEnds < now, "Commit stage is still in progress");
    require(votes[_voteId].revealEnds > now, "Voting stage has ended");
    require(keccak256(_vote) == userBalances[msg.sender].userCommits[_voteId].secret, "wrong vote claim");
    require(!userBalances[msg.sender].userCommits[_voteId].revealed, "User has already revealed");

    userBalances[msg.sender].userCommits[_voteId].revealed = true;
    bytes32 weightBytes = Decoder.readBytes32(_vote, 1);
    uint weight = Decoder.bytes32ToUint(weightBytes);
    
    require((userBalances[msg.sender].tokens - userBalances[msg.sender].lockedTokens) > weight, "User does not enough balance");
    
    uint8 vote = Decoder.readUint8(_vote, 0);
    
    require(vote <= votes[_voteId].options.length, "User is trying to vote on non-excistent option");
    
    userBalances[msg.sender].lockedTokens = userBalances[msg.sender].lockedTokens + weight;
    
    votes[_voteId].votes[vote] = votes[_voteId].votes[vote] + weight;
  }
  
  function pickWinner(
    uint _voteId
  ) 
  public 
  returns(bytes32) {
    require(!votes[_voteId].ended);
    require(votes[_voteId].revealEnds < now);
    uint winner;
    for (uint i = 0; i < votes[_voteId].options.length; i++) {
      if (votes[_voteId].votes[i] > winner) {
        winner = i;
      }
    }
    votes[_voteId].ended = true;
    return votes[_voteId].options[winner];
  }
}