pragma solidity ^0.4.24;

library Decoder {
  function readBytes32(
    bytes data, 
    uint256 offset
  ) internal 
  pure 
  returns(bytes32) {
    offset += 32;
    bytes32 result;
    assembly {result := mload(add(data, offset))}
    return result;
  }

  function bytes32ToUint(
    bytes32 data
  ) internal 
  pure 
  returns(uint256) {
    uint256 number;
    for(uint i=0;i<data.length;i++){
      number = number + uint(data[i])*(2**(8*(data.length-(i+1))));
    }
    return number;
  }
  
  function readUint8(
    bytes data, 
    uint256 offset
  ) internal 
  pure 
  returns(uint8) {
    offset += 32;
    uint8 result;
    assembly {result := div(mload(add(data, offset)), exp(256, 31))}
    return result;
  }
}
