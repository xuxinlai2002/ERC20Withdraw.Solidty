// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
    @title Interface to be used with withdraw asset from ESC
    @author ELASTOS Systems.
 */
interface IWithdraw {
    function withdraw(uint64 destChainType, address tokenAddress, address owner, string memory recipient, uint256 amount, uint256 fee) external payable;

    function setPendingWithdrawTx(bytes32 pendingID, bytes32[] memory txs) external;

    function getPendingTxsByPendingID(bytes32 pendingID) external view returns(bytes32[] memory);

    function getPendingWithdrawTxs() external view returns(bytes32[] memory);

    function confirmWithdrawTx(bytes32 pendingID, bytes[] memory signatures) external;

    function changeSubmitters(address[] memory newSubmitters) external;

    function deleteSubmitterSender() external returns (bool);

    function getVersion() external view returns(string memory);

    /**
        @notice Sets a new resource for handler contracts that use the IERCHandler interface,
        and maps the {handlerAddress} to {resourceID} in {_resourceIDToHandlerAddress}.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param destinationChainType destination chain to withdraw.
     */
    function adminSetChainHandler(address handlerAddress, uint64  destinationChainType) external;

    function getHandlerByChainType(uint64 chainType) external view returns(address);
}
