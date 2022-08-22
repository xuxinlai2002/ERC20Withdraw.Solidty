// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

library BytesToTypes {
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
}