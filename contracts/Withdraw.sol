
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./handlers/HandlerHelpers.sol";
import "./handlers/ERC20Handler.sol";
import "./interfaces/IERCHandler.sol";
import "./utils/BytesToTypes.sol";
import "hardhat/console.sol";

/**
    @title Facilitates deposits, creation and votiing of deposit proposals, and deposit executions.
    @author ChainSafe Systems.
 */
contract Withdraw {

    uint256 public _fee;
    address private _owner;

    // chainType => handler address
    mapping(bytes32 => address) public _chainTypeToHandlerAddress;
    address[] _signers;
    string _version;
    bytes32[] private _withdrawTxs;

    event WithdrawAsset(
        bytes32 chainType,
        string desition,
        uint256 amount
    );

    event VersionChanged (
        string indexed oldVersion,
        string indexed newVersion
    );

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(_owner == msg.sender, "sender doesn't have admin role");
    }

    /**
        @notice Initializes Bridge, creates and grants {msg.sender} the admin role,
        creates and grants {initialRelayers} the relayer role.
     */
    function __ERC20Withdraw_init(
    ) public {
        require(_owner == address(0), "allready init");
        _owner = msg.sender;
        _version = "v0.0.1";
    }

    function getVersion() external view returns(string memory) {
        return _version;
    }

    function changeVersion(string memory version) external onlyOwner {
        emit VersionChanged(_version, version);
        _version = version;
    }

    /**
        @notice Sets a new resource for handler contracts that use the IERCHandler interface,
        and maps the {handlerAddress} to {resourceID} in {_resourceIDToHandlerAddress}.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param destinationChainType destination chain to withdraw.
     */
    function adminSetChainHandler(
        address handlerAddress,
        bytes32  destinationChainType
    ) external onlyOwner {
        require(handlerAddress != address(0), "handler is null");
        _chainTypeToHandlerAddress[destinationChainType] = handlerAddress;
    }

    function getHandlerByChainType(bytes32 chainType) public view returns(address){
        return _chainTypeToHandlerAddress[chainType];
    }

    function withdraw(bytes32 destChainType, address tokenAddress, address owner, string memory recipient, uint256 amount, uint256 fee) external {
        address handler = _chainTypeToHandlerAddress[destChainType];
        require(handler != address(0), "not register handler");
        require(fee >= 100000000000000 && fee % 10000000000 == 0);//todo need confirm this value
        IERCHandler(handler).withdraw(tokenAddress, owner, recipient, amount);
        emit WithdrawAsset(destChainType,recipient, amount);
    }

    function withdrawTxsReceived(bytes32[] memory txids) external {
        for (uint i = 0; i < txids.length; i ++) {
            if (this.isWithdrawTx(txids[i])) {
                continue;
            }
            _withdrawTxs.push(txids[i]);
        }
    }

    function isWithdrawTx(bytes32 txid) external view returns (bool) {
        for (uint i = 0; i < _withdrawTxs.length; i++) {
            if (_withdrawTxs[i] == txid) {
                return true;
             }
        }
        return false;
    }

    function getPendingWithdrawTxs() external view returns(bytes32[] memory) {
        return _withdrawTxs;
    }

    function confirmWithdrawTx(bytes32[] memory txids) external {
        for (uint i = 0; i < txids.length; i ++) {
            uint j = 0;
            for (j = 0; j < _withdrawTxs.length; j++) {
                if (_withdrawTxs[j] == txids[i]) {
                    deleteConfirmTx(j);
                    break;
                }
            }
            if (j == _withdrawTxs.length) {
                revert("not withdraw tx");
            }
        }
    }

    function deleteConfirmTx(uint index) internal {
        require(index < _withdrawTxs.length, "out of bound with widthdraw length");
        delete _withdrawTxs[index];
        for (uint i = index; i < _withdrawTxs.length - 1; i++ ) {
           _withdrawTxs[i] = _withdrawTxs[i + 1];
        }
       _withdrawTxs.pop();
    }

}





