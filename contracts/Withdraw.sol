
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./handlers/HandlerHelpers.sol";
import "./handlers/ERC20Handler.sol";
import "./interfaces/IERCHandler.sol";


/**
    @title Facilitates deposits, creation and votiing of deposit proposals, and deposit executions.
    @author ChainSafe Systems.
 */
contract Withdraw {

    uint256 public _fee;
    address private _owner;
    string _version;

    // chainType => handler address
    mapping(bytes32 => address) public _chainTypeToHandlerAddress;

    event WithdrawAsset(
        bytes32 chainType,
        string desition,
        uint256 amount
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
        @param fee cross chain fee
        @param version version
     */
    function __ERC20Withdraw_init(
        uint256 fee,
        string memory version
    ) public {
        _fee = fee;
        _owner = msg.sender;
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

    function withdraw(bytes32 destChainType, address tokenAddress, address owner, string memory recipient, uint256 amount) external {
        address handler = _chainTypeToHandlerAddress[destChainType];
        require(handler != address(0), "not register handler");
        IERCHandler(handler).withdraw(tokenAddress, owner, recipient, amount);
        emit WithdrawAsset(destChainType,recipient, amount);
    }

}





