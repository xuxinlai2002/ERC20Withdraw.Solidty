const {
    readConfig, sleep
} = require('./utils/helper')

const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let owner = accounts[0];

    let withdrawAddress = await readConfig("config", "Withdraw");
    console.log("withdraw Address :",withdrawAddress);

    const withdraw = await ethers.getContractFactory('Withdraw',owner);

    const instanceV1 = await withdraw.attach(withdrawAddress);
    let version = await instanceV1.getVersion();
    console.log("instanceV1", instanceV1.address, "version", version);

    const submitters = [
        "0x53781E106a2e3378083bdcEdE1874E5c2a7225f8"
    ];

    const withdrawV2 = await ethers.getContractFactory("WithdrawV2", owner);
    await upgrades.upgradeProxy(
        withdrawAddress,
        withdrawV2,
        {args: [submitters]},
        {call:"__ERC20Withdraw_init"},

    );
    await sleep(10000);
    console.log('withdraw upgraded ! ');

    const instanceV2 = await withdrawV2.attach(withdrawAddress);
    version = await instanceV2.getVersion();
    console.log("instanceV2", instanceV2.address, "version", version);

}

main();
