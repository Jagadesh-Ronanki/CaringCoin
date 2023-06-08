// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/backend/contracts/Constants.sol";

contract DeployConstants is Script {
  function run() external {
    vm.startBroadcast();
    Constants constants = new Constants();
    address _constants = address(constants);
    console.log("Constants Deployed: ", _constants);
    vm.stopBroadcast();
  }
}