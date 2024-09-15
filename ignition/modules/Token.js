const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("TokenModule", (m) => {
  const token = m.contract("Marketplace", [
    "0xf11a08f385297fC5F1149f95d47978DbD0670913",
  ]);
  // const token = m.contract("NFT");
  return { token };
});

module.exports = TokenModule;
