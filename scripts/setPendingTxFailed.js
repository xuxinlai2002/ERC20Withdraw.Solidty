const {
    attachWithdrawContract, readConfig, sleep, attachERC20
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');
const {utils} = require("ethers");
require("@nomiclabs/hardhat-web3");

let pendingTxs = [
    "0x78c1645758228af7255c596cdc276d95ce47b52533b0bf14bd0136cf61560f01"
];

const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let owner = accounts[1];
    let withdrawAddress = await readConfig("config", "Withdraw");
    let contract = await attachWithdrawContract(owner, withdrawAddress);
    console.log("attachWithdrawContract address:", contract.address);

    let bytesData=[];
    for(let i = 0; i < pendingTxs.length; i++) {
        bytesData = bytesData.concat(web3.utils.hexToBytes((pendingTxs[i])));
    }
    let pendingID = utils.keccak256(bytesData);
    console.log("pendingID", pendingID);
    let sig = await web3.eth.sign(pendingID, owner.address);

    let tx = await contract.setPendingWithdrawTxFailed(pendingID, [sig]);
    console.log("setPendingWithdrawTxFailed tx", tx.hash)
    await sleep(15000);

    let txs = await contract.getFailedPendingTxs();
    console.log("getFailedPendingTxs:", txs);

    let tokenAddress = await readConfig("config", "WBTC");
    let wbtc = await attachERC20(owner, tokenAddress);
    let balance = await wbtc.balanceOf(owner.address);
    console.log("before balance", balance.toString(), hEether.utils.formatUnits(balance, 8));


    let handler = await readConfig("config", "BTCHandler");
    let handlerBalance = await wbtc.balanceOf(handler);
    console.log("handlerBalance balance", handlerBalance.toString(), hEether.utils.formatUnits(handlerBalance, 8));

    tx = await contract.retrieve(pendingTxs[0]);
    console.log("retrieve tx", tx.hash)
    await sleep(15000);
    balance = await wbtc.balanceOf(owner.address);
    console.log("behind balance", balance.toString(), hEether.utils.formatUnits(balance, 8));

    txs = await contract.getFailedPendingTxs();
    console.log("getFailedPendingTxs:", txs);

}

main();
