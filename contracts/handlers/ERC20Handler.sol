// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./HandlerHelpers.sol";
import "../ERC20Safe.sol";

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

/**
    @title Handles ERC20 deposits and deposit executions.
    @author ChainSafe Systems.
    @notice This contract is intended to be used with the Bridge contract.
 */
contract ERC20Handler is HandlerHelpers,ERC20Safe{

    constructor(address withdrawAddress) public {
        _withdrawAddress = withdrawAddress;
    }

    /**
        @notice Used to manually release ERC20 tokens from ERC20Safe.
        @param tokenAddress Address of token contract to burn.
        @param tokenOwner Address to burn tokens to.
        @param recipient Address of destination.
        @param amount The amount of ERC20 tokens to withdraw.
     */
    function withdraw(
        address tokenAddress,
        address tokenOwner,
        string memory recipient,
        uint256 amount
    ) external onlyWithdraw override {
        uint256 balance = IERC20(tokenAddress).balanceOf(tokenOwner);
        require(balance >= amount, "Insufficient funds");
        require(bytes(recipient).length > 0 , "recipient is empty");
//        burnERC20(tokenAddress, tokenOwner, amount); //TODO debug this why burn failed
    }

}
