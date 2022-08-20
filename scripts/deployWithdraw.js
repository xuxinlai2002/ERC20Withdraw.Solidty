const {
    deployWithdrawContract, deployERC20Handler,targetChainType, sleep,
    writeConfig, attachERC20, readConfig
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');

const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);
    let args = { fee:0,version:"v1.0.0" };
    let accounts = await hEether.getSigners();
    let admin = accounts[0];
    let withdrawContract = await deployWithdrawContract(admin, args);
    console.log("withdrawContract proxy address:", withdrawContract.address);
    writeConfig("config", "config", "Withdraw", withdrawContract.address);

    args.withdrawAddress = withdrawContract.address;
    let ercHandlerContract = await deployERC20Handler(admin,args);
    console.log("erc Handler Contract :",ercHandlerContract.address);
    writeConfig("config", "config", "BTCHandler", ercHandlerContract.address);

    await withdrawContract.adminSetChainHandler(ercHandlerContract.address, targetChainType);
    await sleep(6000);
    let handler = await withdrawContract.getHandlerByChainType(targetChainType);
    console.log("register getHandlerByChainType :", handler);

    let wbtcAddress = readConfig("config", "WBTC");
    console.log("read wbtc address :", wbtcAddress);
    let wbtc = await attachERC20(admin, wbtcAddress);
    // const tx = await wbtc.approve(ercHandlerContract.address, 3 );
    // await sleep(10000);
    // let alloweance = await wbtc.allowance(admin.address, ercHandlerContract.address);
    // console.log("alloweance :", alloweance);
    process.exit(0)
}

main();
