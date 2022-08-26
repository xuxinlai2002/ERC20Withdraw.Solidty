<h1 align="center">ERC20 Withdraw</h1>
<p align="center">ERC20 Withdraw is to withdraw assets transferred from other chains to the ESC chain to the project on the original chain. </p>
<div align="center">

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![type-badge](https://img.shields.io/badge/build-solidity-green)](https://img.shields.io/badge/build-solidity-green)
</div>

## Dependencies
Make sure you're running a version of node compliant with the `engines` requirement in `package.json`, or install Node Version Manager [`nvm`](https://github.com/creationix/nvm) and run `nvm use` to use the correct version of node.

Requires `nodejs` ,`yarn` and `npm`.

```shell
# node -v 
v16.0.0
# yarn version
yarn version v1.22.17 
# npm -v
8.5.3
```

## Quick Start
```shell
# Development library installation
yarn install
npm install dotenv 

# contract compilation
yarn compile

# contract unit test
## run all tests
yarn test
## run certain test file
yarn test test/withdrawTx.test.js   
```
> Make sure you are using the original npm registry.  
> `npm config set registry http://registry.npmjs.org`



## hardhat.config.js

The configuration file of hardhat can configure the network and account private key deployed by the contract. For private key security, the account private key needs to be configured in the .env environment variable. If multiple private keys are required, use [,] to split.
#### .env
```
PRIVATE_LIST="0x9aede013637152836b14b423dabef30c9b880ea550dbec132183ace7ca6177ed,0x58a6ea95c61cea23a426935067fe276674978be0f12aeaae72faa84ecf893cb8"

```

#### hardhat.config.js
```
require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-waffle')
require("@nomiclabs/hardhat-web3")
require('hardhat-deploy')

require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config()

let privateKeys = process.env.PRIVATE_LIST;
privateKeys = privateKeys.split(",")
module.exports = {
  networks: {
    testnet: {
        url: `https://api-testnet.elastos.io/esc`,
        accounts: privateKeys
    },
    local: {
      url: `http://127.0.0.1:6111`,
      accounts: privateKeys
    },

    hardhat: {
      chainId:100,
      gas:202450000,
      blockGasLimit:300_000_000,
      accounts: [
        {privateKey:"0x9aede013637152836b14b423dabef30c9b880ea550dbec132183ace7ca6177ed",balance:"10000000000000000000000"},
        {privateKey:"0x58a6ea95c61cea23a426935067fe276674978be0f12aeaae72faa84ecf893cb8",balance:"10000000000000000000000"},
        {privateKey:"0xcb93f47f4ae6e2ee722517f3a2d3e7f55a5074f430c9860bcfe1d6d172492ed0",balance:"10000000000000000000000"},
      ]
    }
  },
  solidity: '0.6.12',
  namedAccounts: {
    deployer: 0
  },
}


```

The hardhat configuration file can configure different networks, the content is the rpc interface , the private key of the deployment contract and the operation contract.

## Deploy WBTC

```
./deployWBTC.sh
```
This script runs the scripts/deployWBTC.js file. This contract is used to test the ERC20 contract needed to withdraw to the BTC network.

## Deploy the withdraw contract.
```
./deployWithdraw.sh 
```

This script runs the scripts/deployWithdraw.js file. Used to deploy withdraw.sol contracts and related contracts.

## Withdraw WBTC

```
./withdraw.sh
```


## Contribution
Thank you for considering to help out with the source code! We welcome contributions from anyone on the internet, and are grateful for even the smallest of fixes!

If you'd like to contribute to ERC20Withdraw.solidity, please fork, fix, commit and send a pull request for the maintainers to review and merge into the main code base. 


## License  

ERC20Withdraw.solidity is an GPL v3.0-licensed open source project with its ongoing development made possible entirely by the support of the elastos team. 

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.
