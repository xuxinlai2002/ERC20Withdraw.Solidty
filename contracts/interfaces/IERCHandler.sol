// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
    @title Interface to be used with handlers that support ERC20s and ERC721s.
    @author ChainSafe Systems.
 */
interface IERCHandler {
    /**
        @notice Marks {contractAddress} as mintable/burnable.
        @param contractAddress Address of contract to be used when making or executing deposits.
     */
    function setBurnable(address contractAddress) external;
    /**
        @notice Used to manually release funds from ERC safes.
        @param tokenAddress Address of token contract to release.
        @param recipient Address to release tokens to.
        @param amount the amount of ERC20 tokens.
     */
    function withdraw(address tokenAddress, address tokenOwner, string memory recipient, uint256 amount) external;
}
