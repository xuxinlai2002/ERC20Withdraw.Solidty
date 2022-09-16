// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
    @title Interface to be used with withdraw asset from ESC
    @author ELASTOS Systems.
 */
interface IWithdraw {

    struct PendingTx {
        address owner;
        bytes32 tx;
        uint64 chainType;
        uint256 amount;
    }

    event WithdrawAsset(
        address sender,
        uint64 chainType,
        string desition,
        uint256 amount
    );

    event NewSubmitterCommit (
        uint indexed totalCount,
        uint indexed nowCount
    );

    event NewSubmitterChanged (
        address[] indexed accounts
    );

    event PendingWithdrawTxs (
        bytes32 indexed pengingID,
        bytes32[] txs
    );

    event ConfirmWithdrawTxs (
        bytes32 indexed pengingID,
        bytes32 targetTXID,
        bytes32[] txs
    );

    event WithdrawTxFailed (
        bytes32 indexed pendingID,
        bytes32[] txs
    );

    event RegisterToken (
        uint64 indexed chainType,
        address indexed tokenAddress
    );

    function withdraw(uint64 destChainType, address owner, string memory recipient, uint256 amount, uint256 fee) external payable;

    function setPendingWithdrawTx(bytes32 pendingID, PendingTx[] memory txs) external;

    function getPendingTxsByPendingID(bytes32 pendingID) external view returns(bytes32[] memory);

    function getPendingWithdrawTxs() external view returns(bytes32[] memory);

    function confirmWithdrawTx(bytes32 pendingID, bytes32 targetTXID, bytes[] memory signatures) external;

    function setPendingWithdrawTxFailed(bytes32 pendingID, bytes[] memory signatures) external;

    function getFailedPendingTxs() external view returns(bytes32[] memory);

    function changeSubmitters(address[] memory newSubmitters) external;

    function deleteSubmitterSender() external returns (bool);

    function getVersion() external view returns(string memory);

    function adminRegisterToken(address handlerAddress, uint64  destinationChainType, address tokenAddress) external;

    function getHandlerByChainType(uint64 chainType) external view returns(address);
}
