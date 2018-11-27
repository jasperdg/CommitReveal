const utils = require ("web3-utils")
const pad = require("pad-left")

class VoteHash {
  constructor(voteValue, weightValue) {
    this.vote = {
      type: "bytes",
      value: voteValue,
    }
    
    this.weight = {
      type: "bytes",
      value: this.encode(weightValue),
    }
    
    this.bytes = "0x" + this.vote.value + this.weight.value

    this.hash = utils.soliditySha3(this.bytes)
  }
  
  encode(data) {
    return pad(data.toString(16), 64,'0')
  }
  
}

module.exports = VoteHash