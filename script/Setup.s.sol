// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import '../src/GovernorContract.sol';

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

contract Setup is Script {
  bytes[] functionCalls;
  address[] addressesToCall;
  uint256[] values;
  function run() external {
    address _constants = vm.envAddress("CONSTANTS_ADDRESS");
    IConstants constants = IConstants(_constants);
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    // import addresses
    address priceConversionAddr = constants.getPriceConversion();
    address userRegistryAddr = constants.getUserRegistry();
    address postRegistryAddr = constants.getPostRegistry();
    address handlerAddr = constants.getHandler();
    address govTokenAddr = constants.getGovernanceToken();
    address variablesAddr = constants.getVariables();

    // setup user registry
    IUserRegistry userRegistry = IUserRegistry(userRegistryAddr);
    userRegistry.setHandler(handlerAddr);
    userRegistry.setGovernanceToken(govTokenAddr);

    // setup post registry
    IPostRegistry postRegistry = IPostRegistry(postRegistryAddr);
    postRegistry.setHandler(handlerAddr);
    postRegistry.setUserRegistry(userRegistryAddr);
    
    // setup handler
    IHandler handler = IHandler(handlerAddr);
    handler.setUserRegistry(userRegistryAddr);
    handler.setPriceConversion(priceConversionAddr);
    handler.setVariables(variablesAddr);

    // setup price conversion
    IPriceConversion priceConversion = IPriceConversion(priceConversionAddr);

    // setup governance token
    IGovernanceToken govToken = IGovernanceToken(govTokenAddr);
    govToken.setUserRegistry(userRegistryAddr);
    govToken.setVariables(variablesAddr);

    vm.stopBroadcast();

    // contributor 1 with 100 usd in account
    uint256 contribPrivateKey1 = vm.envUint("CONTRIBUTOR_KEY_1");
    vm.startBroadcast(contribPrivateKey1);
    address contributor1 = vm.addr(contribPrivateKey1);
    vm.deal(contributor1, 100 ether);
    if (!userRegistry.getUserDetails(contributor1).registered){
      userRegistry.registerUser();
    }
    uint256 contribAmt = priceConversion.UsdtoEth(100);
    bool added = userRegistry.addContributionBal{value:contribAmt}(contributor1);
    require(added, "Failed to add contribution amount for contributor 1");
    vm.stopBroadcast();

    // contributor 2 with 100 USD in account
    uint256 contribPrivateKey2 = vm.envUint("CONTRIBUTOR_KEY_2");
    vm.startBroadcast(contribPrivateKey2);
    address contributor2 = vm.addr(contribPrivateKey2);
    vm.deal(contributor2, 100 ether);
    if (!userRegistry.getUserDetails(contributor2).registered){
      userRegistry.registerUser();
    }
    added = userRegistry.addContributionBal{value:contribAmt}(contributor2);
    require(added, "Failed to add contribution amount for contributor 2");
    vm.stopBroadcast();

    // post as creator 1
    uint256 creatorPrivateKey1 = vm.envUint("CREATOR_KEY");
    vm.startBroadcast(creatorPrivateKey1);
    address creator = vm.addr(creatorPrivateKey1);
    vm.deal(creator, 100 ether);
    if (!userRegistry.getUserDetails(creator).registered){
      userRegistry.registerUser();
    }
    uint256 postId = postRegistry.createPost("Creator1");
    console.log("Post Id: ", postId);
    vm.stopBroadcast();

    // appreciate post
    vm.startBroadcast(contributor1);
    IUserRegistry.User memory user = userRegistry.getUserDetails(creator);
    uint level = user.level;
    // appreciate until user reaches level 2
    // uint threshold = handler.getBaseThreshold();
    // uint256 thresholdWei  = priceConversion.UsdtoEth(threshold);
    uint256 maxAppreciation = (2**level - level);
    uint256 maxAppreciationEth = priceConversion.UsdtoEth(maxAppreciation);
    // 1
    bool appreciated = postRegistry.appreciate{value:maxAppreciationEth}(postId);
    require(appreciated, "Appreciation Failed");
    // 2
    appreciated = postRegistry.appreciate{value:maxAppreciationEth}(postId);
    require(appreciated, "Appreciation Failed");
    // 3
    appreciated = postRegistry.appreciate{value:maxAppreciationEth}(postId);
    require(appreciated, "Appreciation Failed");
    vm.stopBroadcast();

    vm.startBroadcast(contributor2);
    // appreciate until user reaches level 2
    // uint threshold = handler.getBaseThreshold();
    // uint256 thresholdWei  = priceConversion.UsdtoEth(threshold);
    // 1
    appreciated = postRegistry.appreciate{value:maxAppreciationEth}(postId);
    require(appreciated, "Appreciation Failed");
    // 2
    appreciated = postRegistry.appreciate{value:maxAppreciationEth}(postId);
    require(appreciated, "Appreciation Failed");
    // 3
    appreciated = postRegistry.appreciate{value:maxAppreciationEth}(postId);
    require(appreciated, "Appreciation Failed");
    vm.stopBroadcast();

    // perform withdraw
    IPostRegistry.Post memory post = postRegistry.getPost(postId);
    address postCreator = post.creator;
    vm.startBroadcast(postCreator);
    bool withdrawn = handler.withdraw(postCreator); 
    require(withdrawn, "Failed to withdraw");
    vm.stopBroadcast();

    // level 2
    // mint CaringToken
    vm.startBroadcast(postCreator);
    govToken.safeMint(postCreator);
    govToken.delegate(postCreator);
    IUserRegistry.User memory creatorDetails = userRegistry.getUserDetails(postCreator);
    uint256 tokenId = creatorDetails.tokenId;
    console.log("TokenId: ", tokenId);
    vm.stopBroadcast();

    // governor propose change in variables
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

    uint256 VOTING_DELAY = constants.VOTING_DELAY();
    vm.warp(block.timestamp + VOTING_DELAY + 1);
    vm.roll(block.number + VOTING_DELAY + 1);
    console.log("Proposal State:", uint256(governor.state(proposalId)));

    // 2. Vote
    string memory reason = "I like a do da cha cha";
    // 0 = Against, 1 = For, 2 = Abstain for this example
    uint8 voteWay = 1;
    vm.prank(postCreator);
    governor.castVoteWithReason(proposalId, voteWay, reason);

    uint256 VOTING_PERIOD = constants.VOTING_PERIOD();
    vm.warp(block.timestamp + VOTING_PERIOD + 1);
    vm.roll(block.number + VOTING_PERIOD + 1);
    console.log("Proposal State:", uint256(governor.state(proposalId)));

    // 3. Queue
    bytes32 descriptionHash = keccak256(abi.encodePacked(description));
    governor.queue(addressesToCall, values, functionCalls, descriptionHash);
    uint256 MIN_DELAY = constants.MIN_DELAY();
    vm.warp(block.timestamp + MIN_DELAY + 1);
    vm.roll(block.number + MIN_DELAY + 1);

     // 4. Execute
    governor.execute(addressesToCall, values, functionCalls, descriptionHash);

    // check
    IVariables variables = IVariables(variablesAddr);
    console.log(variables.retriveBaseThreshold());
  }
}

    /* // contributor 1 with 50 USD in account
    address contributor1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; 
    vm.startBroadcast(contributor1);
    userRegistry.registerUser();
    uint256 contribAmt = priceConversion.UsdtoEth(50);
    bool added = userRegistry.addContributionBal{value:contribAmt}(contributor1);
    require(added, "Failed to add contribution amount");
    vm.stopBroadcast();
    
    // contributor 1 with 100 USD in account
    address contributor2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; 
    vm.startBroadcast(contributor2);
    userRegistry.registerUser();
    contribAmt = priceConversion.UsdtoEth(100);
    added = userRegistry.addContributionBal{value:contribAmt}(contributor2);
    require(added, "Failed to add contribution amount");
    vm.stopBroadcast();

    // post as creator 1
    address creator1 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    vm.startBroadcast(creator1);
    uint256 postId = postRegistry.createPost("Creator1");
    vm.stopBroadcast();

    // appreciate post
    vm.startBroadcast(contributor1);
    IUserRegistry.User memory user = userRegistry.getUserDetails(creator1);
    uint level = user.level;
    
    // appreciate until user reaches level 2
    uint threshold = handler.getBaseThreshold();
    uint256 thresholdWei  = priceConversion.UsdtoEth(threshold);
    uint256 maxAppreciation = (2**level - level);
    uint256 maxAppreciationEth = priceConversion.UsdtoEth(maxAppreciation);
    while (user.appreciationBalance < thresholdWei) {
      bool appreciated = postRegistry.appreciate{value:maxAppreciationEth}(postId);
      require(appreciated, "Appreciation Failed");
    }
    vm.stopBroadcast();
    
    // perform withdraw
    IPostRegistry.Post memory post = postRegistry.getPost(postId);
    address creator = post.creator;
    vm.startBroadcast(creator);
    bool withdrawn = handler.withdraw(creator); 
    require(withdrawn, "Failed to withdraw");
    vm.stopBroadcast();


    // level 2
    // mint CaringToken
    vm.startBroadcast(creator);
    govToken.safeMint(creator);
    
    IUserRegistry.User memory creatorDetails = userRegistry.getUserDetails(creator);
    uint256 tokenId = creatorDetails.tokenId;
    console.log(tokenId);
    vm.stopBroadcast(); */