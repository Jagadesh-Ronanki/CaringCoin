// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console.sol';
import '../src/backend/contracts/_Variables.sol';

interface IConstants {
  function getTimeLock() external returns (address);
  function setVariables(address) external;
}

contract DeployVariables is Script {
  function run() external {
    console.log("Deploying Variable Contract");
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);
    address timeLockAddress = constants.getTimeLock();

    Variables variables = new Variables();
    address _variables = address(variables);
    console.log("Variables Contract Deployed at: ", _variables);
    constants.setVariables(_variables);

    variables.storeLevelToGovern(2);
    variables.storeBaseThreshold(3);
    variables.storePerWithdrawal(10);
    variables.transferOwnership(timeLockAddress);
    console.log("Variables contract ownership transfered to ", timeLockAddress);

    vm.stopBroadcast();

    
  }
}