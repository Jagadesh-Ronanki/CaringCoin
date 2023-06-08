// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/backend/contracts/UserRegistry.sol";

interface IConstants {
  function setUserRegistry(address) external;
}

contract DeployUserRegistry is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    UserRegistry userRegistry = new UserRegistry();
    address _userRegistry = address(userRegistry);
    console.log("UserRegistry Deployed: ", _userRegistry);
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);
    constants.setUserRegistry(_userRegistry);

    vm.stopBroadcast();
  }
}