// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./HandlerHelpers.sol";
import "../ERC20Safe.sol";

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

contract ERC20Handler is HandlerHelpers,ERC20Safe{
    function init (
        address withdrawAddress
    ) public {
        require(_withdrawAddress == address(0), "ERC20Handler is initialized");
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

    function confirmTx(uint64 destChainType, uint256 amount) external onlyWithdraw override {
        address tokenAddress = _chainTypeToTokenContractAddress[destChainType];
        require(tokenAddress != address(0), "not register chainType");
        bool res = IERC20(tokenAddress).approve(address(this), amount);
        require(res, "confirmTx approve failed");
        burnERC20(tokenAddress, address(this), amount);
    }
}
