// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./HandlerHelpers.sol";
import "../ERC20Safe.sol";

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

contract ERC20Handler is HandlerHelpers,ERC20Safe{

    constructor(address withdrawAddress) public {
        _withdrawAddress = withdrawAddress;
    }

    function withdraw(
        uint64 destChainType,
        address tokenOwner,
        string memory recipient,
        uint256 amount
    ) external onlyWithdraw override {
        address tokenAddress = _chainTypeToTokenContractAddress[destChainType];
        uint256 balance = IERC20(tokenAddress).balanceOf(tokenOwner);
        require(balance >= amount, "Insufficient funds");
        require(bytes(recipient).length > 0 , "recipient is empty");
        lockERC20(tokenAddress, tokenOwner, address(this), amount);
    }
}
