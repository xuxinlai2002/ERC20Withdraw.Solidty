/* External Imports */
const { ethers, network } = require('hardhat')
const chai = require('chai')
const { solidity } = require('ethereum-waffle')
const { expect } = chai
chai.use(solidity)
const { utils } = require('ethers')

const {
  sleep,
  deployERC20,
  deployERC20WithdrawContract,
  deployERC20Handler
} = require("../scripts/utils/helper")

describe(`WBTC Test `, () => {

  let admin,alice,chainID,wbtcContract,erc20WithdrawContract
  let gasPrice = 0x02540be400,gasLimit=0x7a1200
  before(`load accounts and chainID`, async () => {

    [admin,alice] = await ethers.getSigners()
    console.log("admin : ",admin.address," alice : ",alice.address);

    let args = { fee:0,expiry:0,version:"v1.0.0",gasPrice,gasLimit }
   
    chainID = await getChainId();
    console.log("chainID is :" + chainID);
    let totalSupply = utils.parseEther("100000000000000");
    wbtcContract = await deployERC20("WBTC","WBTC",totalSupply,18,admin,args.gasPrice,args.gasLimit);
    console.log("wbtcContract address :",wbtcContract.address);

    //1.预挖到某个账号
    let preAmount = utils.parseEther("100");
    await wbtcContract.transfer(alice.address,preAmount);

    //deploy ERC20 Withdraw Contract
    erc20WithdrawContract = await deployERC20WithdrawContract(admin,args);
    console.log("erc20WithdrawContract address :",erc20WithdrawContract.address);

    // deploy Handle Contract
    args.withdrawAddress = erc20WithdrawContract.address;
    let ercHandlerContract = await deployERC20Handler(admin,args);
    console.log("erc Handler Contract :",ercHandlerContract.address);
    
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
