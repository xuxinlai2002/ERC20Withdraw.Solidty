
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../interfaces/IERCHandler.sol";

/**
    @title Function used across handler contracts.
    @author ChainSafe Systems.
    @notice This contract is intended to be used with the Bridge contract.
 */
contract HandlerHelpers is IERCHandler {
    address public _withdrawAddress;

    // chainType => token contract address
    mapping (uint64 => address) public _chainTypeToTokenContractAddress;

    modifier onlyWithdraw() {
        _onlyWithdraw();
        _;
    }

    function _onlyWithdraw() private view {
        require(msg.sender == _withdrawAddress, "sender must be bridge contract");
    }

    function registerToken(uint64 destChainType, address tokenAddress) external override onlyWithdraw {
        _chainTypeToTokenContractAddress[destChainType] = tokenAddress;
    }

    function withdraw(uint64 destChainType, address tokenOwner, string memory recipient, uint256 amount) external virtual override {}

    function confirmTx(uint64 destChainType, uint256 amount) external virtual override {}

    function retrieve(uint64 destChainType, address sender, uint256 amount) external virtual override {}
}