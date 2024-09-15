require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
module.exports = {
  solidity: "0.8.10",
  compilers: [
    {
      version: "0.8.10",
    },
  ],
  networks: {
    klaytn: {
      url: "https://public-en-baobab.klaytn.net",
      accounts: [process.env.PRIV_KEY],
      chainId: 1001,
    },
  },
  etherscan: {
    apiKey: {
      klaytn: "unnecessary",
    },
    customChains: [
      {
        network: "klaytn",
        chainId: 1001,
        urls: {
          apiURL: "https://api-baobab.klaytnscope.com/api",
          browserURL: "https://baobab.klaytnscope.com",
        },
      },
    ],
  },
};
