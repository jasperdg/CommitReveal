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
    string[] options;
    uint[] votes;
    uint commitEnds;
    uint revealEnds;
    bool ended;
  }
  
  mapping (address => User) userBalances;
  mapping (uint => Vote) votes;

  constructor() 
  public {
    // One day:
      // uint commitEnds = now + 60 * 60 * 24; // One day for the example, pass as parameter in the future
  // uint revealEnds = commitEnds + 60 * 60 * 24; // One day for the example, pass as parameter in the future

    // One minute for development
    uint commitEnds = now + 10 seconds; // One Minute for the example, pass as parameter in the future
    uint revealEnds = commitEnds + 10 seconds; // One Minute for the example, pass as parameter in the future
      
    // Set some initial data
    votes[0] = Vote(
      "EveryDapp", 
      new string[](0), 
      new uint[](0), 
      commitEnds, 
      revealEnds, 
      false
    );
    votes[1] = Vote(
      "ETH", 
      new string[](0), 
      new uint[](0), 
      commitEnds, 
      revealEnds, 
      false
    );
    
    votes[0].options.push("no");
    votes[0].options.push("yes");
    votes[0].votes.push(0);
    votes[0].votes.push(0);
    
    votes[1].options.push("no");
    votes[1].options.push("yes");
    votes[1].votes.push(0);
    votes[1].votes.push(0);
    
    userBalances[msg.sender] = User(100, 0);
    userBalances[address(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c00)] = User(100, 0);
  }
  
  // Example: 0, 0x63187ec60a67cd31ea7056a075f212643363da65bc07cbae5615aa8f06ae99e9
  function commit(
    uint _voteId, 
    bytes32 _commitSecret
  ) public {
    require(votes[_voteId].commitEnds > now, "Commit stage is done");
    require(!userBalances[msg.sender].userCommits[_voteId].voted, "User has already participated in this vote");
    userBalances[msg.sender].userCommits[_voteId] = Commit(_commitSecret, true);
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
  returns(string) {
    require(!votes[_voteId].ended);
    // require(votes[_voteId].revealEnds < now);
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