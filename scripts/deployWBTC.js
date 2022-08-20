const {
    deployERC20, writeConfig
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');
const {utils} = require("ethers");

const main = async () => {

    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners()
    let wbtc = await deployERC20("WBTC","BTC", 22000000, 18, accounts[0], );
    console.log("contract wbtc address:", wbtc.address);

    writeConfig("config", "config", "WBTC", wbtc.address);
}

main();
