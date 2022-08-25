const {
    deployERC20, writeConfig, sleep
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

    let preAmount = 100;
    await wbtc.transfer(accounts[1].address,preAmount);
    await sleep(10000);
    let balance = await wbtc.balanceOf(accounts[1].address);
    console.log("accounts[1]", accounts[1].address, "balance", balance.toString());
}

main();
