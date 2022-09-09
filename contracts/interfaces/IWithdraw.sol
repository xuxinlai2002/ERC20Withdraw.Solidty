// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
    @title Interface to be used with withdraw asset from ESC
    @author ELASTOS Systems.
 */
interface IWithdraw {

    struct PendingTx {
        bytes32 tx;
        uint64 chainType;
        uint256 amount;
    }

    function withdraw(uint64 destChainType, address owner, string memory recipient, uint256 amount, uint256 fee) external payable;

    function setPendingWithdrawTx(bytes32 pendingID, PendingTx[] memory txs) external;

    function getPendingTxsByPendingID(bytes32 pendingID) external view returns(bytes32[] memory);

    function getPendingWithdrawTxs() external view returns(bytes32[] memory);

    function confirmWithdrawTx(bytes32 pendingID, bytes[] memory signatures) external;

    function changeSubmitters(address[] memory newSubmitters) external;

    function deleteSubmitterSender() external returns (bool);

    function getVersion() external view returns(string memory);

    function adminRegisterToken(address handlerAddress, uint64  destinationChainType, address tokenAddress) external;

    function getHandlerByChainType(uint64 chainType) external view returns(address);
}
