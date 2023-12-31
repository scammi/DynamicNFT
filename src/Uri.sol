// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract UriTest {
    function uri() public pure returns (string memory) {
        string[2] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" />';
        parts[1] = '</svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1]));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Bag #', toString(1), '", "description": "Loot is randomized adventurer you want.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    function getColor(uint256 value) public pure returns (string memory) {
        // Define the maximum value and range of brightness
        uint256 maxValue = 10**18; // Maximum value (adjust as needed)
        uint256 maxBrightness = 255; // Maximum brightness (adjust as needed)

        // Calculate the brightness based on the value
        uint256 brightness = (value * maxBrightness) / maxValue;

        // Generate the hexadecimal color
        bytes3 color = bytes3(uint24(brightness << 16 | brightness << 8 | brightness));

        // Convert the color to a string representation
        bytes memory colorString = new bytes(6);
        for (uint8 i = 0; i < 3; i++) {
            uint8 nibble1 = uint8(color[i]) >> 4;
            uint8 nibble2 = uint8(color[i]) & 0x0F;
            colorString[i * 2] = bytes1(nibble1 > 9 ? nibble1 + 0x37 : nibble1 + 0x30);
            colorString[i * 2 + 1] = bytes1(nibble2 > 9 ? nibble2 + 0x37 : nibble2 + 0x30);
        }

        return string(colorString);
    }

}

library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}