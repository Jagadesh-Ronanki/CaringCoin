require("@nomicfoundation/hardhat-foundry");
require("@nomiclabs/hardhat-waffle");
/** @type import('hardhat/config').HardhatUserConfig */
const { networks } = require("./networks")

require("dotenv").config()

const SOLC_SETTINGS = {
  optimizer: {
    enabled: true,
    runs: 1_000,
  },
}

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: SOLC_SETTINGS,
      },
      {
        version: "0.7.0",
        settings: SOLC_SETTINGS,
      },
      {
        version: "0.6.6",
        settings: SOLC_SETTINGS,
      },
      {
        version: "0.4.24",
        settings: SOLC_SETTINGS,
      },
    ],
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      accounts: process.env.PRIVATE_KEY
        ? [
            {
              privateKey: process.env.PRIVATE_KEY,
              balance: "10000000000000000000000",
            },
          ]
        : [],
    },
    ...networks,
  }
};