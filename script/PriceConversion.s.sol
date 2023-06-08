// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/backend/contracts/PriceConversion.sol";
import "./HelperConfig.sol";
import "../src/backend/test/mocks/MockV3Aggregator.sol";

interface IConstants {
  function setPriceConversion(address) external;
}

contract DeployPriceConversion is Script, HelperConfig {
    uint8 constant DECIMALS = 18;
    int256 constant INITIAL_ANSWER = 2000e18;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();

        (, , , , , address priceFeed, , , ) = helperConfig
            .activeNetworkConfig();

        if (priceFeed == address(0)) {
            priceFeed = address(new MockV3Aggregator(DECIMALS, INITIAL_ANSWER));
        }

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying PriceConversion Contract...");
        PriceConversion priceConvertion = new PriceConversion(priceFeed);
        address _priceConversion = address(priceConvertion);
        console.log("PriceConversion Deployed: ", _priceConversion);
        address _constants = vm.envAddress("CONSTANTS_ADDRESS");
        IConstants constants = IConstants(_constants);
        constants.setPriceConversion(_priceConversion);

        vm.stopBroadcast();
    }
}
