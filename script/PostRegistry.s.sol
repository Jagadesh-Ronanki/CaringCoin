// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/backend/contracts/PostRegistry.sol";

interface IConstants {
  function setPostRegistry(address) external;
}

contract DeployPostRegistry is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);
    PostRegistry postRegistry = new PostRegistry();
    address _postRegistry = address(postRegistry);
    console.log("PostRegistry Deployed: ", _postRegistry);
    constants.setPostRegistry(_postRegistry);
    
    vm.stopBroadcast();
  }
}