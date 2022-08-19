const fs = require('fs')
const path = require('path')
const { ethers,upgrades } = require("hardhat");

const writeConfig = async (fromFile,toFile,key, value) => {

    let fromFullFile = getPath(fromFile);
    let contentText = fs.readFileSync(fromFullFile,'utf-8');
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

async function deployERC20(name,symbol,amount,decimals,account,gasPrice,gasLimit){

    const dErc20Factory = await ethers.getContractFactory("MockERC20",account);
    const dErc20Contract = await dErc20Factory.deploy(
        name,symbol,amount,decimals,
        { gasPrice: gasPrice, gasLimit: gasLimit}
    )
    return dErc20Contract;

}

async function attachERC20(account,address,gasPrice,gasLimit){

    const dErc20Factory = await ethers.getContractFactory("MockERC20",account);
    const dErc20Contract = await dErc20Factory.attach(
        address,
        { gasPrice: gasPrice, gasLimit: gasLimit}
    )
    return dErc20Contract;

}

async function deployWithdrawContract(account,args) {

    const Factory__ERC20Withdraw = await ethers.getContractFactory('Withdraw',account)
    
    const ERC20Withdraw = await upgrades.deployProxy(
        Factory__ERC20Withdraw, 
        [args.fee,args.version],
        { initializer: '__ERC20Withdraw_init' },
        { gasPrice: args.gasPrice, gasLimit: args.gasLimit}
    );
    
    return ERC20Withdraw;

}

async function attachERC20WithdrawContract(account,tokenAddress) {

    const Factory__ERC20Withdraw = await ethers.getContractFactory('ERC20Withdraw',account)    
    let ERC20Withdraw  = await Factory__ERC20Withdraw.connect(account).attach(tokenAddress); 
    return ERC20Withdraw;

}

async function deployERC20Handler(account,args) {

    const Factory__Erc20Handler = await ethers.getContractFactory('ERC20Handler',account)
    Erc20Handler = await Factory__Erc20Handler.connect(account).deploy(
        args.withdrawAddress,
        { gasPrice: args.gasPrice, gasLimit: args.gasLimit}
    );

    console.log("✓ ERC20Handler contract deployed")
    return Erc20Handler;
}


module.exports = {
    writeConfig,
    readConfig, 
    sleep,
    log,

    deployERC20,
    deployWithdrawContract,
    deployERC20Handler

}