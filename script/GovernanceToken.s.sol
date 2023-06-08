// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/backend/contracts/_GovernanceToken.sol";

interface IConstants {
  function setGovernanceToken(address) external;
}

contract DeployGovernanceToken is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    address deployer = vm.addr(deployerPrivateKey);
    console.log("Deploying Governance Token Contract...");
    GovernanceToken govToken = new GovernanceToken();
    address _govToken = address(govToken);
    console.log("GovernanceToken Deployed: ", _govToken);
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);
    constants.setGovernanceToken(_govToken);

    // delegate vote to deployer
    console.log("Delegating to:", deployer);
    delegateVote(govToken, deployer);
    console.log("Delegated!");
    vm.stopBroadcast();
  }

  function delegateVote(GovernanceToken governanceToken, address delegatedAccount) internal {
    governanceToken.delegate(delegatedAccount);
  }
}