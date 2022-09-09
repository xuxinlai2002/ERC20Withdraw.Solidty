const {
    readConfig, sleep
} = require('./utils/helper')

const { ethers: hEether,upgrades } = require('hardhat');


const main = async () => {
    let chainId = await getChainId();
    console.log("chainId is :" + chainId);

    let accounts = await hEether.getSigners();
    let owner = accounts[0];

    let handler = await readConfig("config", "BTCHandler");
    console.log("handler Address :", handler);

    let withdraw = await readConfig("config", "Withdraw");
    console.log("withdraw Address :", withdraw);


    const handlerv2 = await ethers.getContractFactory("ERC20Handler", owner);
    await upgrades.upgradeProxy(
        handler,
        handlerv2,
        {args: [withdraw]},
        {call:"init"},
    );
    await sleep(20000);
    console.log('handler upgraded ! ');

}

main();
