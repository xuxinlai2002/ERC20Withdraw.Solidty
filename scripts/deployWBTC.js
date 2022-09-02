const {
    deployERC20, writeConfig, sleep
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');
const {parseEther, parseUnits} = require("ethers/lib/utils");

const main = async () => {

    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();

    const decimal = 8;
    let amount = parseUnits("22000000", decimal);
    console.log("amount", amount)
    let wbtc = await deployERC20("WBTC","BTC", amount, decimal, accounts[0]);
    console.log("contract wbtc address:", wbtc.address);

    writeConfig("config", "config", "WBTC", wbtc.address);

    let preAmount = parseUnits("100", decimal);
    await wbtc.transfer(accounts[1].address,preAmount);
    await sleep(15000);
    let balance = await wbtc.balanceOf(accounts[1].address);
    console.log("accounts[1]", accounts[1].address, "balance", balance.toString(), "btc", hEether.utils.formatUnits(balance, 8));
}

main();
