const CommitRevealVote = artifacts.require("CommitRevealVote")

const VoteHash = require("./VoteHash")
const moment = require("moment")
const tryCatch = require("./exceptions.js").tryCatch
const errTypes = require("./exceptions.js").errTypes

contract('Tests for the commit reveal scheme', (accounts) => {
  let contract;
  const owner = accounts[0]
  const account = accounts[1]
  const ownerVoteHash = new VoteHash("01", 20)
  const accountVoteHash = new VoteHash("00", 10)
  const commitEnd = moment().add(1, "minute").format('X');
  const revealEnd = moment().add(90, "second").format('X');

  it('should be able to get the contract', async () => {
    contract = await CommitRevealVote.new()
  })

  it('should be able to start new vote', async () => {
    await contract.addVote("EveryDapp", ["01", "02"], commitEnd, revealEnd)
  })

  it('users should be able to commit a vote', async () => {
    await contract.commit(0, ownerVoteHash.hash, {from: owner})
    await contract.commit(0, accountVoteHash.hash, {from: account})
  })

  it('after waiting the difference between commitEnd and commitReveal the votes should be able to be revealed | Includes timeout ->', async () => {
    await new Promise((resolve, reject) => {
      setTimeout(() =>{
        resolve()
      }, 60000)
    })
    
    await contract.reveal(0, ownerVoteHash.bytes, {from: owner})
    await contract.reveal(0, accountVoteHash.bytes, {from: account})
  })

  it('after the reveal phase is over the winner should be picked | Includes timeout ->', async() => {
    await new Promise((resolve, reject) => {
      setTimeout(() =>{
        resolve()
      }, 30000)
    })
    await contract.pickWinner(0, {from: owner});
  })
})
