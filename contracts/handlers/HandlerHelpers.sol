
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../interfaces/IERCHandler.sol";

/**
    @title Function used across handler contracts.
    @author ChainSafe Systems.
    @notice This contract is intended to be used with the Bridge contract.
 */
contract HandlerHelpers is IERCHandler{
    address public _withdrawAddress;

    // token contract address => is burnable
    mapping(address => bool) public _burnList;

    modifier onlyWithdraw() {
        _onlyWithdraw();
        _;
    }

    function _onlyWithdraw() private view {
        require(msg.sender == _withdrawAddress, "sender must be bridge contract");
    }
    
    /**
    @notice First verifies {contractAddress} is whitelisted, then sets {_burnList}[{contractAddress}]
    to true.
    @param contractAddress Address of contract to be used when making or executing deposits.
    */
    function setBurnable(address contractAddress) external onlyWithdraw override {
        _setBurnable(contractAddress);
    }


    function _setBurnable(address contractAddress) internal {
        _burnList[contractAddress] = true;
    }

    function withdraw(address tokenAddress, address tokenOwner, string memory recipient, uint256 amount) external virtual override {}
}