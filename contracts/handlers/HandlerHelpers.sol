
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
    @title Function used across handler contracts.
    @author ChainSafe Systems.
    @notice This contract is intended to be used with the Bridge contract.
 */
contract HandlerHelpers {
    address public _withdrawAddress;

    // resourceID => token contract address
    mapping(bytes32 => address) public _resourceIDToTokenContractAddress;

    // token contract address => resourceID
    mapping(address => bytes32) public _tokenContractAddressToResourceID;

    // token contract address => is whitelisted
    mapping(address => bool) public _contractWhitelist;
    
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
        @param resourceID ResourceID to be used when making deposits.
        @param contractAddress Address of contract to be called when a deposit is made and a deposited is executed.
     */
    function setResource(bytes32 resourceID, address contractAddress)
        external
        onlyWithdraw
    {
        _setResource(resourceID, contractAddress);
    }

    function _setResource(bytes32 resourceID, address contractAddress)
        internal
    {
        _resourceIDToTokenContractAddress[resourceID] = contractAddress;
        _tokenContractAddressToResourceID[contractAddress] = resourceID;

        _contractWhitelist[contractAddress] = true;
    }

    /**
    @notice First verifies {contractAddress} is whitelisted, then sets {_burnList}[{contractAddress}]
    to true.
    @param contractAddress Address of contract to be used when making or executing deposits.
    */
    function setBurnable(address contractAddress) external onlyWithdraw {
        _setBurnable(contractAddress);
    }


    function _setBurnable(address contractAddress) internal {
        require(
            _contractWhitelist[contractAddress],
            "provided contract is not whitelisted"
        );
        _burnList[contractAddress] = true;
    }

    
}