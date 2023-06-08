// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console.sol';
import '../src/backend/contracts/_GovernorContract.sol';
import '../src/backend/contracts/_TimeLock.sol';
import '../src/backend/contracts/_GovernanceToken.sol';

interface IConstants {
  function setGovernor(address) external;
  function getGovernanceToken() external returns (address);
  function getTimeLock() external returns (address);
  function QUORUM_PERCENTAGE() external pure returns (uint256);
  function VOTING_PERIOD() external pure returns (uint256);
  function VOTING_DELAY() external pure returns (uint256);
}

contract DeployGovernorContract is Script{
  function run() external {
    console.log("Deploying Governor Contract...");

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    // import constants
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);

    address governanceTokenAddress = constants.getGovernanceToken();
    GovernanceToken governanceToken = GovernanceToken(governanceTokenAddress);
    console.log("Governance_address: ", address(governanceToken));

    address timeLockAddress = constants.getTimeLock();
    TimeLock timeLock = TimeLock(payable(timeLockAddress));
    console.log("timelock_address: ", address(timeLock));
    
    uint256 quorumPercentage = constants.QUORUM_PERCENTAGE();
    uint256 votingPeriod = constants.VOTING_PERIOD();
    uint256 votingDelay = constants.VOTING_DELAY();

    GovernorContract governorContract = new GovernorContract(governanceToken, timeLock, quorumPercentage, votingPeriod, votingDelay);
    console.log("Governor deployed at ", address(governorContract));

    constants.setGovernor(payable(address(governorContract)));
  }
}