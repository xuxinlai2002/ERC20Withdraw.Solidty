// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
    @title Interface to be used with handlers that support ERC20s
    @author ChainSafe Systems.
 */
interface IERCHandler {
    /**
        @notice Correlates {destChainType} with {contractAddress}.
        @param destChainType destinationChainType to be used when making withdraw.
        @param tokenAddress Address of contract to be called when a withdraw is made.
     */

    function registerToken(uint64 destChainType, address tokenAddress) external;
    /**
        @notice Used to manually release funds from ERC safes.
        @param destChainType to be used when making withdraw
        @param tokenOwner withdraw this owner of token
        @param recipient Address to withdraw the target chain address.
        @param amount the amount of ERC20 tokens.
     */
    function withdraw(uint64 destChainType, address tokenOwner, string memory recipient, uint256 amount) external;

    function confirmTx(uint64 destChainType, uint256 amount) external;
}
