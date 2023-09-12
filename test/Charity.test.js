const { assert, expect } = require("chai");
const { deployments, ethers } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Charity", async function () {
      let charity;
      let deployer;

      const sendValue = ethers.utils.parseEther("0.1");

      beforeEach(async function () {
        deployer = (await getNamedAccounts()).deployer;
        await deployments.fixture(["all"]);
        charity = await ethers.getContract("Charity", deployer);
      });

      describe("fund", async function () {
        it("Fails if you dont send enogh ETH", async () => {
          await expect(charity.fund()).to.be.reverted;
        });

        it("Updates the amount funded", async () => {
          await charity.fund({ value: sendValue });
          const response = await charity.s_addressToAmount(deployer);
          assert.equal(response.toString(), sendValue.toString());
        });

        it("Only allows the owner to withdraw", async function () {
          const accounts = await ethers.getSigners();
          const connectedContract = await charity.connect(accounts[1]);
          await expect(connectedContract.withdraw()).to.be.reverted;
        });
      });
    });
