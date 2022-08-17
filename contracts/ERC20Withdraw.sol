
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./handlers/HandlerHelpers.sol";
import "./handlers/ERC20Handler.sol";


/**
    @title Facilitates deposits, creation and votiing of deposit proposals, and deposit executions.
    @author ChainSafe Systems.
 */
contract ERC20Withdraw is HandlerHelpers {

    uint256 public _fee;
    uint256 public _expiry;
    address private _owner;
    string _version;

    // destinationChainID => number of deposits
    mapping(uint64 => uint64) public _depositCounts;
    // resourceID => handler address
    mapping(bytes32 => address) public _resourceIDToHandlerAddress;

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
        @param expiry cross chain expiry time setting.
        @param version version
     */
    function __ERC20Withdraw_init(
        uint256 fee,
        uint256 expiry,
        string memory version
    ) public {
        
        _fee = fee;
        _expiry = expiry;
        _owner = msg.sender;
        _version = version;

    }

    /**
        @notice Sets a new resource for handler contracts that use the IERCHandler interface,
        and maps the {handlerAddress} to {resourceID} in {_resourceIDToHandlerAddress}.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param resourceID ResourceID to be used when making deposits.
        @param tokenAddress Address of contract to be called when a deposit is made and a deposited is executed.
     */
    function adminSetResource(
        address handlerAddress,
        bytes32 resourceID,
        address tokenAddress
    ) external onlyOwner {

        _resourceIDToHandlerAddress[resourceID] = handlerAddress;
        ERC20Handler handler = ERC20Handler(handlerAddress);
        handler.setResource(resourceID, tokenAddress);
    }



}





