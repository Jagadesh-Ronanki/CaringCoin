// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Handler.sol";

interface IConstants {
  function setHandler(address) external;
}

contract DeployHandler is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    Handler handler = new Handler();
    address _handler = address(handler);
    console.log("Handler Deployed: ", _handler);
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);
    constants.setHandler(_handler);

    vm.stopBroadcast();
  }
}