require("@nomicfoundation/hardhat-toolbox");
// 私钥
require("dotenv").config({ path: "./.env" });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    testnet: {
      url: "https://exchaintestrpc.okex.org",
      chainId: 65,
      gasPrice: 3000000000,
      accounts: [process.env.PRIVATE_KET],
    },
  },
};
