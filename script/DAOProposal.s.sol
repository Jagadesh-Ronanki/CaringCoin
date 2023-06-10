// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import '../src/backend/contracts/_GovernorContract.sol';

interface IConstants {
  function getPriceConversion() external view returns (address);
  function getUserRegistry() external view returns (address);
  function getPostRegistry() external view returns (address);
  function getHandler() external view returns (address);
  function getGovernanceToken() external view returns (address);
  function getGovernor() external view returns (address);
  function getTimeLock() external view returns (address);
  function getVariables() external view returns (address);
  function MIN_DELAY() external pure returns (uint256);
  function VOTING_DELAY() external pure returns (uint256);
  function VOTING_PERIOD() external pure returns (uint256);
  function QUORUM_PERCENTAGE() external pure returns (uint256);
}

interface IUserRegistry {
  struct User {
    uint256 level;
    bool registered;
    uint256 appreciationBalance;
    uint256 contributionBalance;
    uint256 appreciationsTaken;
    uint256 appreciationsGiven;
    uint256 takenAmt;
    uint256 givenAmt;
    uint256 tokenId;
    bool tokenHolder;
  }
  
  function setHandler(address _handlerAddr) external;
  function setGovernanceToken(address _govToken) external;
  function registerUser() external;
  function addContributionBal(address) external payable returns (bool);
  function getUserDetails(address user) external view returns (User memory);
}

interface IPostRegistry {
  struct Post {
    uint256 id;
    address creator;
    string content;
    uint256 timestamp;
    uint256 appreciationsCnt;
  }
  function setHandler(address _handlerAddr) external;
  function setUserRegistry(address _userRegistryAddr) external;
  function createPost(string memory content) external returns (uint256);
  function appreciate(uint256 postId) external payable returns (bool) ;
  function getPost(uint256 postId) external view returns (Post memory);
}

interface IHandler {
  function setUserRegistry(address _userRegistryAddr) external;
  function setPriceConversion(address _priceConversionAddr) external;
  function receiveAmount(address creator, address appreciator) external payable returns (bool);
  function getBaseThreshold() external view returns (uint256);
  function withdraw(address creator) external payable returns (bool);
  function setVariables(address _variables) external;
}

interface IPriceConversion {
  function getLatestPrice() external returns (uint256, uint256);
  function UsdtoEth(uint) external returns (uint);
}

interface IGovernanceToken {
  function safeMint(address to) external;
  function setUserRegistry(address _userRegistry) external;
  function setVariables(address _variables) external;
  function delegate(address delegatee) external;
}

interface IVariables {
  function retriveBaseThreshold() external view returns (uint256);
}
// END OF INTERFACES =======================

contract DAOProposal is Script {
  bytes[] functionCalls;
  address[] addressesToCall;
  uint256[] values;
  
  IUserRegistry userRegistry;
  IPostRegistry postRegistry;
  IHandler handler;
  IPriceConversion priceConversion;
  IGovernanceToken govToken;
  IConstants constants;
  address variablesAddr;
  
  function setUp() external {
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    constants = IConstants(_constants);
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    // import addresses
    variablesAddr = constants.getVariables();
    vm.stopBroadcast();
  }

  function run() external {
    // governor propose change in variables
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    address governorAddr = constants.getGovernor();
    GovernorContract governor = GovernorContract(payable(governorAddr));

    uint256 valueToStore = 2;
    string memory description = "Like to reduce threshold to 2";
    bytes memory encodedFunctionCall = abi.encodeWithSignature("storeBaseThreshold(uint256)", valueToStore);
    addressesToCall.push(variablesAddr);
    values.push(0);
    functionCalls.push(encodedFunctionCall);
    
    // 1. Propose to the DAO
    uint256 proposalId = governor.propose(addressesToCall, values, functionCalls, description);
    console.log("Proposal State:", uint256(governor.state(proposalId)));
    console.log(proposalId);
    /* uint256 VOTING_DELAY = constants.VOTING_DELAY();
    vm.warp(block.timestamp + VOTING_DELAY + 1);
    vm.roll(block.number + VOTING_DELAY + 1); */
    console.log("Proposal State:", uint256(governor.state(proposalId)));
    bytes32 hash = keccak256(abi.encodePacked(description));
    console.logBytes32(hash);
    console.logAddress(addressesToCall[0]);    
    vm.stopBroadcast();
  }
}