const utils = require ("web3-utils")
const pad = require("pad-left")

const encode = (data) => {
  return pad(data.toString(16), 64,'0')
}

const vote = {
  type: "bytes",
  value: "01" // Yes vote
}

const weight = {
  type: "bytes",
  value: encode(20)
}

const bytes = "0x" + vote.value + weight.value
console.log(bytes)

const hashed = utils.soliditySha3(bytes)
console.log(hashed)

console.log(hashed == 0x63187ec60a67cd31ea7056a075f212643363da65bc07cbae5615aa8f06ae99e9)