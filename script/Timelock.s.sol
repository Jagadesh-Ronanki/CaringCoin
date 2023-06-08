// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console.sol';
import '../src/backend/contracts/_TimeLock.sol';

interface IConstants {
  function setTimeLock(address) external;
  function MIN_DELAY() external pure returns (uint256);
}

contract DeployTimeLock is Script {

  function run() external {
    console.log("Deploying Timelock contract...");
    
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);
    vm.startBroadcast(deployerPrivateKey);

    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);

    uint256 minDelay = constants.MIN_DELAY();
    TimeLock timeLock = new TimeLock(minDelay, new address[](0), new address[](0), deployer);
    console.log("Timelock at ", address(timeLock));
    constants.setTimeLock(payable(address(timeLock)));
  }
}