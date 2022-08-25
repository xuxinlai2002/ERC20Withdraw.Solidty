// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

library Common {
	function bytes32ToString(bytes32 x) internal pure returns(string memory) {
		bytes memory bytesString = new bytes(32);
		uint charCount = 0;
		for(uint i = 0; i < 32; i++) {
		    byte char = byte(bytes32(uint(x) * 2 **(8*i)));
			if (char != 0) {
				bytesString[charCount] = char;
				charCount++;
            }
        }
		bytes memory bytesStringTrimmed = new bytes(charCount);
		for(uint i=0;i < charCount; i++) {
           bytesStringTrimmed[i] = bytesString[i];
        }
		return string(bytesStringTrimmed);
    }

	function deleteArrayList(uint index, address[] storage signers) internal returns (address[] memory) {
		require(index < signers.length, "out of bound with signers length");
		delete signers[index];
		for (uint i = index; i < signers.length - 1; i++ ) {
			signers[i] = signers[i + 1];
		}
		signers.pop();
		return signers;
	}

	function isRepeatContent(bytes[] memory contents) internal pure returns (bool) {
		uint256 len = contents.length;
		for (uint8 i = 0; i < len; i++) {
			for (uint8 j = i + 1; j < len; j++) {
				if (keccak256(contents[i]) == keccak256(contents[j])) {
					return true;
				}
			}
		}
		return false;
	}

	function recoverSigner(bytes32 hash, bytes memory sig) internal pure returns (address) {
		require(sig.length == 65, "signature length error");
		bytes32 r;
		bytes32 s;
		uint8 v;

		// Divide the signature in r, s and v variables
		assembly {
			r := mload(add(sig, 32))
			s := mload(add(sig, 64))
			v := byte(0, mload(add(sig, 96)))
		}

		// Version of signature should be 27 or 28, but 0 and 1 are also possible versions
		if (v < 27) {
			v += 27;
		}

		require(v == 27 || v == 28, "Signature version not match");
		return recoverSigner2(hash, v, r, s);
	}

	function recoverSigner2(bytes32 h, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, h));
		address addr = ecrecover(prefixedHash, v, r, s);
		return addr;
	}
}