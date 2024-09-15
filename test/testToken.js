const { expect } = require("chai");

describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const { ethers } = require("hardhat");

    const [owner] = await ethers.getSigners();

    const hardhatToken = await ethers.deployContract("Floppy");

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
