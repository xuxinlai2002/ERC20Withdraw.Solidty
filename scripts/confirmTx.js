const {
    attachWithdrawContract, readConfig, sleep, attachERC20
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');
const {utils} = require("ethers");

let pendingTxs = [
    "0x78c1645758228af7255c596cdc276d95ce47b52533b0bf14bd0136cf61560f01"
];

let btcTx = "0x34d37bc60d648fe51948b6705bd6a31ff6e720fd0b3e8da8e672ea9ae9707aa2";
const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let owner = accounts[0];
    let withdrawAddress = await readConfig("config", "Withdraw");
    let contract = await attachWithdrawContract(owner, withdrawAddress);
    console.log("attachWithdrawContract address:", contract.address);

    let txs = await contract.getPendingWithdrawTxs();
    console.log("before confirm getPendingWithdrawTxs:", txs);

    let bytesData=[];
    for(let i = 0; i < pendingTxs.length; i++) {
        bytesData = bytesData.concat(web3.utils.hexToBytes((pendingTxs[i])));
    }
    let pendingID = utils.keccak256(bytesData);
    console.log("pendingID", pendingID);

    txs = await contract.getPendingTxsByPendingID(pendingID);
    console.log("before confirm getPendingTxsByPendingID:", txs);


    let tokenAddress = await readConfig("config", "WBTC");
    let wbtc = await attachERC20(owner, tokenAddress);
    let handler = await readConfig("config", "BTCHandler");
    let handlerBalance = await wbtc.balanceOf(handler);
    console.log("before confirm handlerBalance wbtc balance :", handlerBalance);

    let sig = await web3.eth.sign(pendingID, owner.address);

    let btcTXID = web3.utils.hexToBytes(btcTx);
    let tx = await contract.confirmWithdrawTx(pendingID, btcTXID, [sig]);
    console.log("confirm tx hash:", tx.hash);
    await sleep(10000);

    txs = await contract.getPendingWithdrawTxs();
    console.log("behind confirm getPendingWithdrawTxs:", txs);

    txs = await contract.getPendingTxsByPendingID(pendingID);
    console.log("getPendingTxsByPendingID:", txs);

    handlerBalance = await wbtc.balanceOf(handler);
    console.log("behind confirm handlerBalance wbtc balance :", handlerBalance);
}

main();
