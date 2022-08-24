/* External Imports */
const { ethers } = require('hardhat')
const chai = require('chai')
const { expect } = chai
const { solidity } = require('ethereum-waffle')
chai.use(solidity)

const {
    deployWithdrawContract, sleep
} = require("../scripts/utils/helper")
const {utils} = require("ethers");

describe(`Withdraw Contract Test `, () => {
    let admin = null;
    let withdrawContract;
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

    it(`withdrawTxsReceived test `, async () => {
        try{
            let txids = [
                "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
                "0x7317fbb21447f1b1ef7369d2735dde0dbb440ed7648e4305125c6914b7a4cbf1",
                "0xb0a3dc1f80ceb7999b1f2738a8a7e611c51b55c95fdf1c6da1831f8df78cde89",
                "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
                "0xab47f922ed8029194fced7f8f0e7aebde6cecdf82c83dafa76e844212bf26394"
            ];
            await withdrawContract.withdrawTxsReceived(txids);
            let txs = await withdrawContract.getPendingWithdrawTxs();
            expect(txs.length).to.equal(4);
            let expectList = [
                "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
                "0x7317fbb21447f1b1ef7369d2735dde0dbb440ed7648e4305125c6914b7a4cbf1",
                "0xb0a3dc1f80ceb7999b1f2738a8a7e611c51b55c95fdf1c6da1831f8df78cde89",
                "0xab47f922ed8029194fced7f8f0e7aebde6cecdf82c83dafa76e844212bf26394"
            ];

            await withdrawContract.withdrawTxsReceived(txids);
            txs = await withdrawContract.getPendingWithdrawTxs();

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
            let confirmTx = [
                "0x702b517ae9ee8a33ac0d6b4d77227c02eedbc5aebea3c09d2375caf7f9be7fc1",
                "0x7317fbb21447f1b1ef7369d2735dde0dbb440ed7648e4305125c6914b7a4cbf1",
            ];
            let expectList = [
                "0xb0a3dc1f80ceb7999b1f2738a8a7e611c51b55c95fdf1c6da1831f8df78cde89",
                "0xab47f922ed8029194fced7f8f0e7aebde6cecdf82c83dafa76e844212bf26394"
            ];
            await withdrawContract.confirmWithdrawTx(confirmTx);
            let txs = await withdrawContract.getPendingWithdrawTxs();
            expect(txs.length).to.equal(expectList.length);
            for (let i = 0; i < txs.length; i++) {
                expect(txs[i]).to.equal(expectList[i]);
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