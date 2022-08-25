/* External Imports */
const { ethers, network } = require('hardhat')
const chai = require('chai')
const { solidity } = require('ethereum-waffle')
const { expect } = chai
chai.use(solidity)
const { utils } = require('ethers')

const targetChainType= 1;

const {
  deployERC20,
  deployWithdrawContract,
  deployERC20Handler, sleep
} = require("../scripts/utils/helper")

describe(`WBTC Test `, () => {

  let admin,alice,chainID,wbtcContract,erc20WithdrawContract
  let gasPrice = 0x02540be400,gasLimit=0x7a1200
  before(`load accounts and chainID`, async () => {

    [admin,alice] = await ethers.getSigners()
    console.log("admin : ",admin.address," alice : ",alice.address);

    let args = { fee:0,version:"v1.0.0",gasPrice,gasLimit }
   
    chainID = await getChainId();
    console.log("chainID is :" + chainID);
    let totalSupply = utils.parseEther("100000000000000");
    wbtcContract = await deployERC20("WBTC","WBTC",totalSupply,18,admin,args.gasPrice,args.gasLimit);
    console.log("wbtcContract address :",wbtcContract.address);

    // //1.预挖到某个账号
    let preAmount = utils.parseEther("100");
    await wbtcContract.transfer(alice.address,preAmount);

    //deploy ERC20 Withdraw Contract
    args.submitters = [
      "0x53781E106a2e3378083bdcEdE1874E5c2a7225f8"];
    erc20WithdrawContract = await deployWithdrawContract(admin,args);
    console.log("erc20WithdrawContract address :",erc20WithdrawContract.address);

    // deploy Handle Contract
    args.withdrawAddress = erc20WithdrawContract.address;
    let ercHandlerContract = await deployERC20Handler(admin,args);
    console.log("erc Handler Contract :",ercHandlerContract.address);

    let handler = await erc20WithdrawContract.getHandlerByChainType(targetChainType);
    console.log("before register getHandlerByChainType :",handler);
    await erc20WithdrawContract.adminSetChainHandler(ercHandlerContract.address, targetChainType);

    handler = await erc20WithdrawContract.getHandlerByChainType(targetChainType);
    console.log("behind register getHandlerByChainType :", handler);

    let version = await erc20WithdrawContract.getVersion();
    console.log("version :", version);

    await erc20WithdrawContract.changeVersion("v0.0.2");
    await sleep(10000);
    version = await erc20WithdrawContract.getVersion();
    console.log("change version :", version);
  })
  
  it(`WBTC blance `, async () => {

    try{
      
      let balance = await wbtcContract.balanceOf(alice.address);
      expect(balance).to.equal(utils.parseEther("100"));

    } catch (e) {
      console.log("error ");
      console.log(e);
    }

  })
})
