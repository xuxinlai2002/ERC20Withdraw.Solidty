const {
    readConfig
} = require('./utils/helper')

const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let owner = accounts[0];

    let withdrawAddress = await readConfig("config", "Withdraw");
    console.log("withdraw Address :",withdrawAddress);

    const withdraw = await ethers.getContractFactory('Withdraw',owner)

    await upgrades.upgradeProxy(
        withdrawAddress, 
        withdraw,{from:owner.address}
    );
    console.log('withdraw upgraded ! ');

}

main();
