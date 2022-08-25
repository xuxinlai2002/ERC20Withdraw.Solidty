/* External Imports */
const { ethers } = require('hardhat')
const chai = require('chai')
const { expect } = chai
const { solidity } = require('ethereum-waffle')
chai.use(solidity)
require("@nomiclabs/hardhat-web3");

const {
    deployWithdrawContract, sleep
} = require("../scripts/utils/helper")
const {utils} = require("ethers");
const {sign} = require("eth-crypto");

describe(`Withdraw Contract Test `, () => {
    let admin = null;
    let withdrawContract;
    let pendingID;

    let pendingTxs = [
        "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
        "0x7317fbb21447f1b1ef7369d2735dde0dbb440ed7648e4305125c6914b7a4cbf1",
        "0xb0a3dc1f80ceb7999b1f2738a8a7e611c51b55c95fdf1c6da1831f8df78cde89",
        "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
        "0xab47f922ed8029194fced7f8f0e7aebde6cecdf82c83dafa76e844212bf26394"
    ];

    before(`load accounts and chainID`, async () => {
        let args = { fee:0,version:"v1.0.0" };

        let chainID = await getChainId()
        console.log("chainID is :" + chainID);

        [admin,_] = await ethers.getSigners()
        args.submitters = [
            "0x53781E106a2e3378083bdcEdE1874E5c2a7225f8"];
        withdrawContract = await deployWithdrawContract(admin,args);
        await sleep(10000);
        console.log("withdrawContract address :",withdrawContract.address);
    })

    it(`setPendingWithdrawTx test `, async () => {
        try{
            let index;
            let bytesData=[];
            for(index = 0; index < pendingTxs.length; index++) {
                bytesData = bytesData.concat(web3.utils.hexToBytes((pendingTxs[index])));
            }
            pendingID = utils.keccak256(bytesData);
            let sig = await web3.eth.sign(pendingID, admin.address);

            await withdrawContract.setPendingWithdrawTx(pendingID, pendingTxs, [sig]);
            let txs = await withdrawContract.getPendingWithdrawTxs();
            let expectList = [
                "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
                "0x7317fbb21447f1b1ef7369d2735dde0dbb440ed7648e4305125c6914b7a4cbf1",
                "0xb0a3dc1f80ceb7999b1f2738a8a7e611c51b55c95fdf1c6da1831f8df78cde89",
                "0xab47f922ed8029194fced7f8f0e7aebde6cecdf82c83dafa76e844212bf26394"
            ];

            expect(txs.length).to.equal(expectList.length);
            for (let i = 0; i < txs.length; i++) {
                expect(txs[i]).to.equal(expectList[i]);
            }
        } catch (e) {
            console.log("error ");
            console.log(e);
        }
    })

    it(`confirmWithdrawTx test `, async () => {
        try{
            let newTxs = [
                "0x5b4baedc160ed781d69ecf9e51dfc55a4ec86aa364575546bdafcd22b377cbb2",
                "0x9c0b6f7acda10b1931b19a4854525a46b84e8453cbd1aef8b677be392f34e4ff"
            ];

            let bytesData=[];
            let index = 0;
            for(index = 0; index < newTxs.length; index++) {
                bytesData = bytesData.concat(web3.utils.hexToBytes((newTxs[index])));
            }
            let newPendingID = utils.keccak256(bytesData);
            let sig = await web3.eth.sign(newPendingID, admin.address);

            await withdrawContract.setPendingWithdrawTx(newPendingID, newTxs, [sig]);
            let txs = await withdrawContract.getPendingWithdrawTxs();
            expect(txs.length).to.equal(pendingTxs.length + newTxs.length - 1);

            sig = await web3.eth.sign(pendingID, admin.address);
            await withdrawContract.confirmWithdrawTx(pendingID, [sig]);
            txs = await withdrawContract.getPendingWithdrawTxs();
            expect(txs.length).to.equal(newTxs.length);
            for (let i = 0; i < txs.length; i++) {
                expect(txs[i]).to.equal(newTxs[i]);
            }
        } catch (e) {
            console.log("error ");
            console.log(e);
        }
    })

    it(`change submitters test `, async () => {
        try{
            let newSubmitters = ["0x53781E106a2e3378083bdcEdE1874E5c2a7225f8","0xC1317BA633eaC68eD45bb070c5D0Afe5Bf7C777b"];
           await withdrawContract.changeSubmitters(newSubmitters);
            await sleep(1000);
            let list = await withdrawContract.getSubmitters();
            await sleep(5000);
            expect(newSubmitters.length).to.equal(list.length);
            for (let i = 0; i < list.length; i++) {
                expect(list[i]).to.equal(newSubmitters[i]);
            }
           console.log("nowSubmitters", list);
        } catch (e) {
            console.log("error ");
            console.log(e);
        }
    })
})