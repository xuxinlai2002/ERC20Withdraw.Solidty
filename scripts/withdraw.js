const {
    attachWithdrawContract, sleep, readConfig, targetChainType, attachERC20
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');

const main = async () => {

    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let owner = accounts[1];
    let withdrawAddress = readConfig("config", "Withdraw");
    let contract = await attachWithdrawContract(owner, withdrawAddress);
    console.log("attachWithdrawContract address:", contract.address);

    let target = "37sgjU6oKn8XKZJV8CVVHrjVZ6JWBRceNw";
    let tokenAddress = readConfig("config", "WBTC");

    let wbtc = await attachERC20(owner, tokenAddress);
    let balance = await wbtc.balanceOf(owner.address);
    console.log("before balance", balance.toString(), hEether.utils.formatUnits(balance, 8))

    const withdrawAmount = hEether.utils.parseUnits("1", 8);

    let handler = readConfig("config", "BTCHandler");
    console.log("handler", handler);
    await wbtc.approve(handler, withdrawAmount);
    await sleep(10000);
    let alloweance = await wbtc.allowance(owner.address, handler);
    console.log("alloweance :", alloweance);

    let fee = hEether.utils.parseEther("1")
    let tx = await contract.withdraw(targetChainType, tokenAddress, owner.address, target, withdrawAmount, fee,{value:fee});
    console.log("withdraw tx", tx.hash)
    await sleep(10000)
    balance = await wbtc.balanceOf(owner.address);
    console.log("behind balance", balance, "btc", hEether.utils.formatUnits(balance, 8));
    alloweance = await wbtc.allowance(owner.address, handler);
    console.log("alloweance :", alloweance);

}

main();
