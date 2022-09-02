
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./handlers/HandlerHelpers.sol";
import "./handlers/ERC20Handler.sol";
import "./interfaces/IERCHandler.sol";
import "./interfaces/IWithdraw.sol";
import "./utils/common.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";

contract Withdraw is IWithdraw {
    uint256 public _fee;
    address private _owner;

    // chainType => handler address
    mapping(uint64 => address) private _chainTypeToHandlerAddress;
    mapping(address => bytes32) private _changeSubmitterFlag;
    mapping(bytes32 => address[]) private _changeSubmitterSigners;
    mapping(bytes32 => bytes32[]) private _pendingWithdrawTxsMap;
    bytes32[] private _pendingList;

    address[] internal _submitters;
    string constant  internal _version = "v0.0.1";

    event WithdrawAsset(
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
        bytes32 indexed pengingID
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
        require(_owner == address(0), "already init");
        _owner = msg.sender;
        _submitters = submitters;
    }

    modifier onlySubmitters() {
        address sender = msg.sender;
        require(isSubmitter(sender), "sender is not submitter");
        _;
    }

    function isSubmitter(address sender) private view returns(bool) {
        bool res = false;
        for (uint i = 0; i < _submitters.length; i++) {
            if (sender == _submitters[i]) {
                res = true;
                break;
            }
        }
       return res;
    }

    function getSubmitters() external view returns(address[] memory) {
        return _submitters;
    }

    function changeSubmitters(address[] memory newSubmitters) external override onlySubmitters {
        require(newSubmitters.length > 0, "new submitter is empty");

        address sender = msg.sender;
        bytes32 hash =  _changeSubmitterFlag[sender];
        require(hash == bytes32(0), "already submit new submitters");

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

    function deleteSubmitterSender() external override onlySubmitters returns (bool) {
        address sender = msg.sender;
        bytes32 hash =  _changeSubmitterFlag[sender];
        require(hash != bytes32(0), "already delete this submitter record");
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

    function getVersion() external override view returns(string memory) {
        return _version;
    }

    /**
        @notice Sets a new resource for handler contracts that use the IERCHandler interface,
        and maps the {handlerAddress} to {resourceID} in {_resourceIDToHandlerAddress}.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param destinationChainType destination chain to withdraw.
     */
    function adminSetChainHandler(address handlerAddress, uint64  destinationChainType) external override onlyOwner {
        require(handlerAddress != address(0), "handler is null");
        _chainTypeToHandlerAddress[destinationChainType] = handlerAddress;
    }

    function getHandlerByChainType(uint64 chainType) external override view returns(address) {
        return _chainTypeToHandlerAddress[chainType];
    }

    function withdraw(uint64 destChainType, address tokenAddress, address owner, string memory recipient, uint256 amount, uint256 fee) external override payable {
        address handler = _chainTypeToHandlerAddress[destChainType];
        require(handler != address(0), "not register handler");
        require(fee >= 1000000000000000000 && fee % 1000000000000000000 == 0);//todo need confirm this value now 1ELA
        IERCHandler(handler).withdraw(tokenAddress, owner, recipient, amount);
        emit WithdrawAsset(destChainType,recipient, amount);
        safeTransferFee(fee);
    }

    function safeTransferFee(uint256 fee) public {
        uint count = _submitters.length;
        uint percent = SafeMath.div(fee, count);
        for(uint i = 0; i < count; i++) {
            (bool success, ) = _submitters[i].call{value: percent}(new bytes(0));
            require(success, "safeTransfer: transfer failed");
        }
    }

    function setPendingWithdrawTx(bytes32 pendingID, bytes32[] memory txs) external override onlySubmitters {
        require(txs.length > 0, "pending txs is empty");
        bytes32[] memory list = _pendingWithdrawTxsMap[pendingID];
        require(list.length == 0, "already set pendingID");

        _pendingWithdrawTxsMap[pendingID] = txs;

        for (uint i = 0; i < txs.length; i ++) {
            if (this.isWithdrawTx(txs[i])) {
                continue;
            }
            _pendingList.push(txs[i]);
        }
        emit PendingWithdrawTxs(pendingID, txs);
    }

    function verifySignatures(bytes32 msgHash, bytes[] memory sig) internal view returns (bool){
        uint8 i = 0;
        uint8 verifiedNum = 0;
        uint256 sigLen = sig.length;
        address signer;
        require(Common.isRepeatContent(sig) == false, "signature is repeat");
        for (i = 0; i < sigLen; i++) {
            signer = Common.recoverSigner(msgHash, sig[i]);
            require(isSubmitter(signer), "[verifySignatures] signer is not submitter");
            verifiedNum++;
            if (verifiedNum >= _submitters.length * 2  / 3) {
                return true;
            }
        }
        return false;
    }

    function isWithdrawTx(bytes32 txID) external view returns (bool) {
        for (uint i = 0; i < _pendingList.length; i++) {
            if (_pendingList[i] == txID) {
                return true;
            }
        }
        return false;
    }

    function getPendingTxsByPendingID(bytes32 pendingID) external override view returns(bytes32[] memory) {
        return _pendingWithdrawTxsMap[pendingID];
    }

    function getPendingWithdrawTxs() external override view returns(bytes32[] memory) {
       return _pendingList;
    }

    function confirmWithdrawTx(bytes32 pendingID, bytes[] memory signatures) external override {
        bytes32[] memory txs = _pendingWithdrawTxsMap[pendingID];
        require(txs.length > 0, "[confirmWithdrawTx] pendingID is not found");

        bool res = verifySignatures(pendingID, signatures);
        require(res, "[confirmWithdrawTx] verified signature failed");
        for (uint i = 0; i < txs.length; i ++) {
            uint j = 0;
            for (j = 0; j < _pendingList.length; j++) {
                if (_pendingList[j] == txs[i]) {
                    deleteConfirmTx(j);
                    break;
                }
            }
        }
        delete _pendingWithdrawTxsMap[pendingID];
        emit ConfirmWithdrawTxs(pendingID);
    }

    function deleteConfirmTx(uint index) internal {
        require(index < _pendingList.length, "out of bound with widthdraw length");
        delete _pendingList[index];
        for (uint i = index; i < _pendingList.length - 1; i++ ) {
            _pendingList[i] = _pendingList[i + 1];
        }
        _pendingList.pop();
    }
}





