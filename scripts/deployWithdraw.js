const {
    deployWithdrawContract, deployERC20Handler,targetChainType, sleep,
    writeConfig, attachERC20, readConfig
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');

const submitters = [
    "0x53781E106a2e3378083bdcEdE1874E5c2a7225f8"
];

const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);
    let args = { fee:0,version:"v1.0.0",submitters: submitters};
    let accounts = await hEether.getSigners();
    let admin = accounts[0];
    let withdrawContract = await deployWithdrawContract(admin, args);
    console.log("withdrawContract proxy address:", withdrawContract.address);
    writeConfig("config", "config", "Withdraw", withdrawContract.address);

    args.withdrawAddress = withdrawContract.address;
    let ercHandlerContract = await deployERC20Handler(admin,args);
    console.log("erc Handler Contract :",ercHandlerContract.address);
    writeConfig("config", "config", "BTCHandler", ercHandlerContract.address);

    let wbtcAddress = await readConfig("config", "WBTC");
    console.log("read wbtc address :", wbtcAddress);

    let tx = await withdrawContract.adminRegisterToken(ercHandlerContract.address, targetChainType, wbtcAddress);
    console.log("adminRegisterToken", "tx.hash", tx.hash);
    await sleep(10000);
    let handler = await withdrawContract.getHandlerByChainType(targetChainType);
    console.log("register getHandlerByChainType :", handler);

    process.exit(0)
}

main();
