// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Variables is Ownable {
  uint256 private levelToGovern;
  uint256 private baseThreshold;
  uint256 private perWithdrawal;
  uint256 private variables;
  
  event updatedLevelToGovern(uint256 value);
  event updatedBaseThreshold(uint256 _threshold);
  event updatedPerWithdrawal(uint256 _percentage);
  event updatedVariables(uint256 _percentage);

  function storeLevelToGovern(uint256 _level) public onlyOwner {
    levelToGovern = _level;
    emit updatedLevelToGovern(_level);
  } 
  
  function storeBaseThreshold(uint256 _threshold) public onlyOwner {
    baseThreshold = _threshold;
    emit updatedBaseThreshold(_threshold);
  }
  
  function storePerWithdrawal(uint256 _percentage) public onlyOwner {
    perWithdrawal = _percentage;
    emit updatedPerWithdrawal(_percentage);
  }

  function retriveLevelToGovern() public view returns (uint256) {
    return levelToGovern;
  }
  
  function retriveBaseThreshold() public view returns (uint256) {
    return baseThreshold;
  }
  
  function retrivePerWithdrawal() public view returns (uint256) {
    return perWithdrawal;
  }
}