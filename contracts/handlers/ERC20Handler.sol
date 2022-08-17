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


    /**
        @param withdrawAddress Contract address of previously deployed Bridge.
        @param initialResourceIDs Resource IDs are used to identify a specific contract address.
        These are the Resource IDs this contract will initially support.
        @param initialContractAddresses These are the addresses the {initialResourceIDs} will point to, and are the contracts that will be
        called to perform various deposit calls.
        @param burnableContractAddresses These addresses will be set as burnable and when {deposit} is called, the deposited token will be burned.
        When {executeProposal} is called, new tokens will be minted.

        @dev {initialResourceIDs} and {initialContractAddresses} must have the same length (one resourceID for every address).
        Also, these arrays must be ordered in the way that {initialResourceIDs}[0] is the intended resourceID for {initialContractAddresses}[0].
     */
    constructor(
        address withdrawAddress,
        bytes32[] memory initialResourceIDs,
        address[] memory initialContractAddresses,
        address[] memory burnableContractAddresses
    ) public{
        require(
            initialResourceIDs.length == initialContractAddresses.length,
            "initialResourceIDs and initialContractAddresses len mismatch"
        );
        _withdrawAddress = withdrawAddress;

        for (uint256 i = 0; i < initialResourceIDs.length; i++) {
            _setResource(initialResourceIDs[i], initialContractAddresses[i]);
        }

        for (uint256 i = 0; i < burnableContractAddresses.length; i++) {
            _setBurnable(burnableContractAddresses[i]);
        }
    }


    function burnERC20(
        bytes32 resourceID,
        address depositer,
        uint256 amount) external onlyWithdraw{

        address tokenAddress = _resourceIDToTokenContractAddress[resourceID];
        burnERC20(tokenAddress, depositer, amount);
    }

    function mintERC20(
        bytes32 resourceID,
        address depositer,
        uint256 amount) external onlyWithdraw{

        address tokenAddress = _resourceIDToTokenContractAddress[resourceID];
        mintERC20(tokenAddress, depositer, amount);
    }

    /**
        @notice Used to manually release ERC20 tokens from ERC20Safe.
        @param tokenAddress Address of token contract to release.
        @param recipient Address to release tokens to.
        @param amount The amount of ERC20 tokens to release.
     */
    function withdraw(
        address tokenAddress,
        address recipient,
        uint256 amount
    ) external onlyWithdraw {
        releaseERC20(tokenAddress, recipient, amount);
    }

}
