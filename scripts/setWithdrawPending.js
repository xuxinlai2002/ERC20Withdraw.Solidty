const {
    attachWithdrawContract, readConfig, sleep
} = require('./utils/helper')

const { ethers: hEether } = require('hardhat');
const {utils} = require("ethers");
require("@nomiclabs/hardhat-web3");

let pendingTxs = [
    "0xadf0863fc7407a59f80cdb77494036cebb53701c56338ec86d362675d0c2c565",
    "0x60801a657ffb9ff0957d77498f54097596ba27b9f2f72c54e5d430f70d6d03b1",
    "0x78c1645758228af7255c596cdc276d95ce47b52533b0bf14bd0136cf61560f01"
];

const main = async () => {

    let chainId = await getChainId();
    console.log("chainId is :" + chainId);
    let args = { fee:0,version:"v1.0.0" }
    let accounts = await hEether.getSigners();
    let owner = accounts[0];
    let withdrawAddress = await readConfig("config", "Withdraw");
    let contract = await attachWithdrawContract(owner, withdrawAddress);
    console.log("attachWithdrawContract address:", contract.address);

    let bytesData=[];
    for(let i = 0; i < pendingTxs.length; i++) {
        bytesData = bytesData.concat(web3.utils.hexToBytes((pendingTxs[i])));
    }
    let pendingID = utils.keccak256(bytesData);
    console.log("pendingID", pendingID);
    // let sig = await web3.eth.sign(pendingID, owner.address);
    const withdrawAmount = hEether.utils.parseUnits("1", 8);
    let pendingObj = [];
    for(let i = 0; i < pendingTxs.length; i++) {
        let tx = {tx:pendingTxs[i], chainType:1, amount:withdrawAmount}
        pendingObj.push(tx);
    }

    let tx = await contract.setPendingWithdrawTx(pendingID, pendingObj);
    console.log("setPendingWithdrawTx tx", tx.hash)
    await sleep(15000);

    let txs = await contract.getPendingWithdrawTxs();
    console.log("getPendingWithdrawTxs:", txs);

    txs = await contract.getPendingTxsByPendingID(pendingID);
    console.log("getPendingTxsByPendingID:", txs);

}

main();
