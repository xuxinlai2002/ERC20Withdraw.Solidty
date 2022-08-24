const {
    attachWithdrawContract, readConfig, sleep
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');

let confirmTxs = [
    "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
    "0x7317fbb21447f1b1ef7369d2735dde0dbb440ed7648e4305125c6914b7a4cbf1",
    "0xb0a3dc1f80ceb7999b1f2738a8a7e611c51b55c95fdf1c6da1831f8df78cde89",
    "0xab47f922ed8029194fced7f8f0e7aebde6cecdf82c83dafa76e844212bf26394"
];

const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);
    let args = { fee:0,version:"v1.0.0" }
    let accounts = await hEether.getSigners();
    let owner = accounts[0];
    let withdrawAddress = readConfig("config", "Withdraw");
    let contract = await attachWithdrawContract(owner, withdrawAddress);
    console.log("attachWithdrawContract address:", contract.address);

    let txs = await contract.getPendingWithdrawTxs();
    console.log("before confirm getPendingWithdrawTxs:", txs);

    let tx = await contract.confirmWithdrawTx(confirmTxs);
    await sleep(10000);

    txs = await contract.getPendingWithdrawTxs();
    console.log("behind confirm getPendingWithdrawTxs:", txs);
}

main();