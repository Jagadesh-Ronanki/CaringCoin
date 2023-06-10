// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IUserRegistry {
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
    function updateAppreciator(address appreciator, uint256 amt) external returns (bool);
    function updateCreator(address creator, uint256) external returns (bool);
    function withdraw(address creator, uint256 fee, uint256 withdrawalThresholdInEth) external;
    function getUserDetails(address user) external view returns (User memory);
}

interface IPriceConversion {
    function UsdtoEth(uint256) external returns (uint256);
}

interface IVariables {
    function retriveBaseThreshold() external view returns (uint256);
    function retrivePerWithdrawal() external view returns (uint256);
}

contract Handler is Ownable {
    IUserRegistry userRegistry;
    IPriceConversion priceConvertor;
    IVariables variables;
    // @TODO VARIABLE 3
    // uint256 private baseThreshold = 3; // USD

    event AddedFunds(address indexed sender, uint256 amount);

    constructor() {
    }

    function setUserRegistry(address _userRegistryAddr) external onlyOwner {
        userRegistry = IUserRegistry(_userRegistryAddr);
    }
    
    function setPriceConversion(address _priceConversionAddr) external onlyOwner {
        priceConvertor = IPriceConversion(_priceConversionAddr);
    }

    function setVariables(address _variables) external onlyOwner {
        variables = IVariables(_variables);
    }    
    
    function receiveAmount(address creator, address appreciator) external payable returns (bool) {
        uint256 level = userRegistry.getUserDetails(creator).level;
        uint256 maxAppreciation = (2**level - level);
        uint256 maxAppreciationEth = priceConvertor.UsdtoEth(maxAppreciation);
        require(msg.value <= maxAppreciationEth, "max appreciation amount exceeds");        
        bool updatedCreator = userRegistry.updateCreator(creator, msg.value);    
        require(updatedCreator, "Failed to update creator");
        bool updatedAppreciator = userRegistry.updateAppreciator(appreciator, msg.value);    
        require(updatedAppreciator, "Failed to update creator");

        return true;
    }

    function withdraw(address creator) external payable returns (bool) {
        IUserRegistry.User memory user = userRegistry.getUserDetails(creator);
        uint256 level = user.level;
        uint256 appreciationBalance = user.appreciationBalance;
        uint256 withdrawalThreshold = calculateWithdrawalThreshold(level);
        uint256 withdrawalThresholdInEth = priceConvertor.UsdtoEth(withdrawalThreshold);
        require(withdrawalThresholdInEth <= appreciationBalance, "Withdrawal threshold not met");
        // @TODO Variable perWithdrawal 10
        uint256 perWithdrawal = variables.retrivePerWithdrawal();
        uint256 fee = withdrawalThresholdInEth * perWithdrawal / 100;
        userRegistry.withdraw(creator, fee, withdrawalThresholdInEth);
        uint256 amt = withdrawalThresholdInEth - fee;
        (bool success, ) = payable(creator).call{value: amt}("");
        require(success, "Withdrawal failed");
        return success;
    }

    function calculateWithdrawalThreshold(uint256 level) public view returns (uint256) {
        uint256 _threshold = variables.retriveBaseThreshold();
        // @TODO Variable perWithdrawal 10
        uint256 perWithdrawal = variables.retrivePerWithdrawal();
        for (uint256 i = 2; i <= level; i++) {
            uint256 percentageIncrease = _threshold * perWithdrawal / 100;
            _threshold += percentageIncrease;
        }

        return _threshold;
    }

    // @TODO remove these utilities add in Variables.sol
    function getBaseThreshold() public view returns (uint256) {
        return variables.retriveBaseThreshold();
    }
    
    receive() external payable {
        emit AddedFunds(msg.sender, msg.value);
    }
}