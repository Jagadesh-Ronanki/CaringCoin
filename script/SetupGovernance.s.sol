// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console.sol';
import '../src/TimeLock.sol';
import '../src/GovernorContract.sol';

interface IConstants {
  function getTimeLock() external returns (address);
  function getGovernor() external returns (address);
}

contract SetupGovernance is Script{
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);
    vm.startBroadcast(deployerPrivateKey);

    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);

    address timeLockAddress = constants.getTimeLock();
    TimeLock timeLock = TimeLock(payable(timeLockAddress));
    console.log("timelock_address: ", address(timeLock));

    address governorAddress = constants.getGovernor();
    GovernorContract governor = GovernorContract(payable(governorAddress));
    console.log("governor_address: ", address(governor));

    // setting contract roles
    bytes32 proposerRole = timeLock.PROPOSER_ROLE();
    bytes32 executorRole = timeLock.EXECUTOR_ROLE();
    bytes32 adminRole = timeLock.TIMELOCK_ADMIN_ROLE();

    console.logBytes32(proposerRole);

    timeLock.grantRole(proposerRole, address(governor));
    timeLock.grantRole(executorRole, address(0));
    timeLock.revokeRole(adminRole, deployer);
  }
}