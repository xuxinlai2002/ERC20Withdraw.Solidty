
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./handlers/HandlerHelpers.sol";
import "./handlers/ERC20Handler.sol";
import "./interfaces/IERCHandler.sol";
import "./utils/common.sol";
//import "hardhat/console.sol";

contract Withdraw {
    uint256 public _fee;
    address private _owner;

    // chainType => handler address
    mapping(bytes32 => address) private _chainTypeToHandlerAddress;
    mapping(address => bytes32) private _changeSubmitterFlag;
    mapping(bytes32 => address[]) private _changeSubmitterSigners;

    address[] _submitters;
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

    event NewSubmitterCommit (
        uint indexed totalCount,
        uint indexed nowCount
    );

    event NewSubmitterChanged (
        address[] indexed accounts
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
        address[] memory submitters
    ) public {
        require(_owner == address(0), "allready init");
        _owner = msg.sender;
        _submitters = submitters;
        _version = "v0.0.1";
    }

    modifier onlySubmitters() {
        _onlySubmitters();
        _;
    }

    function _onlySubmitters() private view {
        address sender = msg.sender;
        bool isSubmitter = false;
        for (uint i = 0; i < _submitters.length; i++) {
            if (sender == _submitters[i]) {
                isSubmitter = true;
                break;
            }
        }
        require(isSubmitter, "sender is not submitter");
    }

    function getSubmitters() external view returns(address[] memory) {
        return _submitters;
    }

    function changeSubmitters(address[] memory newSubmitters) external onlySubmitters {
        require(newSubmitters.length > 0, "new submitter is empty");

        address sender = msg.sender;
        bytes32 hash =  _changeSubmitterFlag[sender];
        require(hash == bytes32(0), "allready submit new submitters");

        hash = getSubmittersHash(newSubmitters);
        _changeSubmitterFlag[sender] = hash;

        address[] storage signers = _changeSubmitterSigners[hash];
        signers.push(sender);
        _changeSubmitterSigners[hash] = signers;

        emit NewSubmitterCommit(_submitters.length, signers.length);

        if (signers.length == _submitters.length) {
            resetChangeSubmitterMap();

            _submitters = newSubmitters;

            emit NewSubmitterChanged(newSubmitters);
        }
    }

    function resetChangeSubmitterMap() internal {
        for (uint i = 0; i < _submitters.length; i ++) {
            bytes32 hash = _changeSubmitterFlag[_submitters[i]];
            delete _changeSubmitterFlag[_submitters[i]];
            delete _changeSubmitterSigners[hash];
        }
    }

    function deleteSubmitterSender() external onlySubmitters returns (bool) {
        address sender = msg.sender;
        bytes32 hash =  _changeSubmitterFlag[sender];
        require(hash != bytes32(0), "allready delete this submitter record");
        delete _changeSubmitterFlag[sender];

        address[] storage signers = _changeSubmitterSigners[hash];
        for(uint i = 0; i < signers.length; i++) {
            if (signers[i] == sender) {
                address[] memory  accounts = Common.deleteArrayList(i, signers);
                _changeSubmitterSigners[hash] = accounts;
                break;
            }
        }

        return true;
    }

    function getSubmittersHash(address[] memory submitters) internal pure returns (bytes32){
        bytes memory allSerialData;
        for (uint256 i = 0; i < submitters.length; i++) {
            bytes memory addressBytes = address2Bytes(submitters[i]);
            allSerialData = mergeBytes(allSerialData,addressBytes);
        }
        bytes32 msgHash = keccak256(allSerialData);
        return msgHash;
    }

    function mergeBytes(bytes memory a, bytes memory b) internal pure returns (bytes memory c) {
        // Store the length of the first array
        uint256 alen = a.length;
        // Store the length of BOTH arrays
        uint256 totallen = alen + b.length;
        // Count the loops required for array a (sets of 32 bytes)
        uint256 loopsa = (a.length + 31) / 32;
        // Count the loops required for array b (sets of 32 bytes)
        uint256 loopsb = (b.length + 31) / 32;
        assembly {
            let m := mload(0x40)
        // Load the length of both arrays to the head of the new bytes array
            mstore(m, totallen)
        // Add the contents of a to the array
            for {
                let i := 0
            } lt(i, loopsa) {
                i := add(1, i)
            } {
                mstore(
                add(m, mul(32, add(1, i))),
                mload(add(a, mul(32, add(1, i))))
                )
            }
        // Add the contents of b to the array
            for {
                let i := 0
            } lt(i, loopsb) {
                i := add(1, i)
            } {
                mstore(
                add(m, add(mul(32, add(1, i)), alen)),
                mload(add(b, mul(32, add(1, i))))
                )
            }
            mstore(0x40, add(m, add(32, totallen)))
            c := m
        }
    }

    function address2Bytes(address a) internal pure returns (bytes memory b){
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
        }
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

    function withdrawTxsReceived(bytes32[] memory txids) external onlySubmitters {
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

    function confirmWithdrawTx(bytes32[] memory txids) external onlySubmitters {
        for (uint i = 0; i < txids.length; i ++) {
            bool find = false;
            uint j = 0;
            for (j = 0; j < _withdrawTxs.length; j++) {
                if (_withdrawTxs[j] == txids[i]) {
                    find = true;
                    deleteConfirmTx(j);
                    break;
                }
            }
            if (find == false) {
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





