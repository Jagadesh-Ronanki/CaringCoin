// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PriceConversion {
    AggregatorV3Interface internal priceFeed;
    using SafeCast for int256;
    using SafeMath for uint256;

    constructor(address _pricefeed) {
        /** Define the priceFeed
        * Network: Sepolia
        * Aggregator: ETH/USD
        * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        */
        priceFeed = AggregatorV3Interface(_pricefeed);
    } 

    function getLatestPrice() public view returns (uint256, uint8) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();
        return (price.toUint256(), decimals);
    }

    function UsdtoEth(uint _amountInUsd) public view returns (uint) {
        (uint256 eth, uint8 decimals) = getLatestPrice();
        return (_amountInUsd.mul(10**(2*decimals)).div(eth)).mul(10**10);
    }
    
    /* Mock Test code */
    /* function getLatestPrice() public pure returns (uint256, uint8) {
        int256 price = 181928245064;
        uint8 decimals = 8;
        return (price.toUint256(), decimals);
    }

    function UsdtoEth(uint _amountInUsd) public pure returns (uint) {
        (uint256 eth, uint8 decimals) = getLatestPrice();
        return (_amountInUsd.mul(10**(2*decimals)).div(eth)).mul(10**10);
    } */
}
