const {
    attachWithdrawContract, sleep, readConfig, targetChainType, attachERC20
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');

const main = async () => {

    let chainId = await getChainId();
    console.log("chainId is :" + chainId);
    let args = { fee:0,version:"v1.0.0" }
    let accounts = await hEether.getSigners();
    let owner = accounts[0];
    let withdrawAddress = readConfig("config", "Withdraw");
    let contract = await attachWithdrawContract(owner, withdrawAddress);
    console.log("attachWithdrawContract address:", contract.address);


    let target = "37sgjU6oKn8XKZJV8CVVHrjVZ6JWBRceNw";
    let tokenAddress = readConfig("config", "WBTC");

    let wbtc = await attachERC20(owner, tokenAddress);
    let balance = await wbtc.balanceOf(owner.address);
    console.log("before balance", balance)

    const withdrawAmount = 1;

    let handler = readConfig("config", "BTCHandler");
    await wbtc.approve(handler, withdrawAmount);
    await sleep(10000);
    let alloweance = await wbtc.allowance(owner.address, handler);
    console.log("alloweance :", alloweance);

    let fee = hEether.utils.parseEther("0.01")
    let tx = await contract.withdraw(targetChainType, tokenAddress, owner.address, target, withdrawAmount, fee);
    console.log("withdraw tx", tx.hash)
    await sleep(10000)
    balance = await wbtc.balanceOf(owner.address);
    console.log("before balance", balance);
    alloweance = await wbtc.allowance(owner.address, handler);
    console.log("alloweance :", alloweance);



}

main();
