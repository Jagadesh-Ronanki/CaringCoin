// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IGovernanceToken {
    function safeMint(address to) external returns (uint256); 
}

contract UserRegistry {

    address owner;
    address handler;
    address governanceToken;

    struct User {
        string name;
        string profileCID;
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

    mapping(address => User) public users;
    event UserRegistered(address indexed id);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(string memory des) {
        require(msg.sender == owner, des);
        _;
    }
    
    modifier onlyHandler(string memory des) {
        require(msg.sender == handler, des);
        _;
    }
    
    modifier onlyGovernanceToken(string memory des) {
        require(msg.sender == governanceToken, des);
        _;
    }

    function setHandler(address _handler) public onlyOwner("Only owner can update handler") {
        handler = _handler;
    }

    function setGovernanceToken(address _tokenAddr) external onlyOwner("Only owner can update governanceTokenAddr") {
        governanceToken = _tokenAddr;
    }

    function registerUser(string memory name, string memory profileCID) external {
        require(!users[msg.sender].registered, "User already registered");
        users[msg.sender] = User(
            name,
            profileCID,
            1,
            true,
            0 wei,
            0 wei,
            0,
            0,
            0 wei,
            0 wei,
            0,
            false
        );
        emit UserRegistered(msg.sender);
    }

    function addContributionBal(address userAddr) public payable returns (bool) {
        require(users[userAddr].registered, "User not registered");
        User storage user = users[userAddr];
        user.contributionBalance = user.contributionBalance + msg.value;
        return true;
    }

    function updateAppreciator(address appreciator, uint256 amt) external onlyHandler("Can't update") returns (bool){
        User storage user = users[appreciator];
        require(user.contributionBalance > amt, "insufficient contribution balance");
        user.appreciationsGiven++;
        user.givenAmt = user.givenAmt + amt;
        user.contributionBalance = user.contributionBalance - amt;
        return true;
    }

    function updateCreator(address creator, uint256 amt) external onlyHandler("Can't update") returns (bool) {
        User storage user = users[creator];
        user.appreciationBalance = user.appreciationBalance + amt;
        user.appreciationsTaken++;
        user.takenAmt = user.takenAmt + amt;
        return true;
    }

    // restrict to be only called by handler
    function withdraw(address creator, uint256 fee, uint256 withdrawalThresholdInEth) external onlyHandler("Can't withdraw") {
        User storage user = users[creator];
        user.level++;
        user.appreciationBalance -= withdrawalThresholdInEth;
        user.contributionBalance += fee;
    }

    function setTokenId(address _user, uint256 _tokenId) external onlyGovernanceToken("Only governance token can update tokenId") {
        IERC721 nft = IERC721(governanceToken);
        require(_user == nft.ownerOf(_tokenId), "Token owner can update details");
        User storage user = users[_user];
        user.tokenId = _tokenId;
        user.tokenHolder = true;
    }

    function getUserDetails(address user) external view returns (User memory) {
        return users[user];
    }

    function isRegistered(address _user) public view returns (bool) {
        return users[_user].registered;
    }

    /* function generateRandomUsername() internal view returns (string memory) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            msg.sender,
            block.prevrandao
        )));
        return string(abi.encodePacked("User_", randomNumber));
    } */
}