const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Mailbox", async () => {
  it("should get mailbox contract", async () => {
    const mailboxContract = await ethers.getContractFactory("Mailbox");
  });
  it("should get total letters in the box", async () => {
    const mailboxContract = await ethers.getContractFactory("Mailbox");
    const mailbox = await mailboxContract.deploy(); // 部署合约
    expect(await mailbox.totalLetters()).to.equal(0); // 查看信件数量
  });
  it("should increase by one when  get new letter", async () => {
    const mailboxContract = await ethers.getContractFactory("Mailbox");
    const mailbox = await mailboxContract.deploy(); // 部署合约
    await mailbox.write("Hello"); // 别人写了一封邮件给自己
    expect(await mailbox.totalLetters()).to.equal(1); // 查看信件数量是否增加了
  });

  it("should get mail contents", async () => {
    const mailboxContract = await ethers.getContractFactory("Mailbox");
    const mailbox = await mailboxContract.deploy(); // 部署合约

    await mailbox.write("Hello"); // 别人写了一封邮件给自己
    const letters = await mailbox.read(); // 获取所有信件
    expect(await letters[0][0]).to.equal("Hello"); // 查看信件内容
  });

  it("should get mail sender", async () => {
    const mailboxContract = await ethers.getContractFactory("Mailbox");
    const mailbox = await mailboxContract.deploy(); // 部署合约

    await mailbox.write("Hello"); // 别人写了一封邮件给自己
    const letters = await mailbox.read(); // 获取所有信件
    expect(await letters[0][1]).to.equal(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    ); // 查看信件内容
  });
});
