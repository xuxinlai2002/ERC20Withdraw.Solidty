const fs = require('fs')
const path = require('path')
const { ethers,upgrades } = require("hardhat");
const {existsSync} = require("fs");
const {parseEther} = require("ethers/lib/utils");

const targetChainType = 1;

const writeConfig = async (fromFile,toFile,key, value) => {

    let fromFullFile = getPath(fromFile);
    if (fs.existsSync(fromFullFile) == false) {
        fs.writeFileSync(fromFullFile, "{}", { encoding: 'utf8' }, err => {})
    }

    let contentText = fs.readFileSync(fromFullFile,'utf-8');
    if (contentText == "") {
        contentText = "{}";
    }
    let data = JSON.parse(contentText);
    data[key] = value;

    let toFullFile = getPath(toFile);
    fs.writeFileSync(toFullFile, JSON.stringify(data, null, 4), { encoding: 'utf8' }, err => {})

}

const readConfig = async (fromFile,key) => {

    let fromFullFile = getPath(fromFile);
    let contentText = fs.readFileSync(fromFullFile,'utf-8');
    let data = JSON.parse(contentText);
   
    return data[key];

}

function getPath(fromFile){
    return  path.resolve(__dirname, '../config/' + fromFile + '.json');
}

const log = (msg) => console.log(`${msg}`)

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function deployERC20(name,symbol,amount,decimals,account){

    const dErc20Factory = await ethers.getContractFactory("MockERC20",account);
    const dErc20Contract = await dErc20Factory.deploy(
        name,symbol,amount,decimals
    )
    return dErc20Contract;

}

async function attachERC20(account,address) {
    const dErc20Factory = await ethers.getContractFactory("MockERC20",account);
    const dErc20Contract = await dErc20Factory.attach(
        address
    )
    return dErc20Contract;
}

async function deployWithdrawContract(account,args) {

    const Factory__ERC20Withdraw = await ethers.getContractFactory('Withdraw',account)
    
    const ERC20Withdraw = await upgrades.deployProxy(
        Factory__ERC20Withdraw, 
        [args.submitters],
        { initializer: '__ERC20Withdraw_init' },
        { gasPrice: args.gasPrice, gasLimit: args.gasLimit}
    );
    
    return ERC20Withdraw;

}

async function attachWithdrawContract(account,withdrawAddress) {

    const Factory__ERC20Withdraw = await ethers.getContractFactory('Withdraw',account)
    let ERC20Withdraw  = await Factory__ERC20Withdraw.connect(account).attach(withdrawAddress);
    return ERC20Withdraw;

}

async function deployERC20Handler(account,args) {
    const Factory__Erc20Handler = await ethers.getContractFactory('ERC20Handler',account)
    const Erc20Handler = await upgrades.deployProxy(
        Factory__Erc20Handler,
        [args.withdrawAddress],
    { initializer: 'init' },
    );
    console.log("✓ ERC20Handler contract deployed")
    return Erc20Handler;
}

function parseBTC(amount) {
    let satoshi = amount * 1e8
    return
}


module.exports = {
    writeConfig,
    readConfig, 
    sleep,
    log,

    deployERC20,
    deployWithdrawContract,
    deployERC20Handler,
    attachWithdrawContract,
    attachERC20,
    targetChainType,
    parseBTC

}