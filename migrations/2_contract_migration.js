var CommitRevealVote = artifacts.require("./CommitRevealVote.sol");

module.exports = function(deployer) {
  deployer.deploy(CommitRevealVote);
};