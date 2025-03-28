// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UintMath} from "./UintMath.sol";

/// @title Strings
/// @author Emmet.Finance
/// @notice String-related interaction logic
library Strings {
    using Strings for string;
    using Strings for uint256;

    uint8 private constant ADDRESS_LENGTH = 20;
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    string private constant StringsError = "Strings Error:";

    /// @notice Gas efficient string concatination
    /// @param strings a fixed length string array
    function _concatStrings(
        string[] memory strings
    ) private pure returns (string memory result) {
        assembly {
            // Calculate total length of the concatenated string
            let totalLength := 0
            let numStrings := mload(strings) // length of the array

            // Loop through the strings and calculate total length
            for {
                let i := 0
            } lt(i, numStrings) {
                i := add(i, 1)
            } {
                let str := mload(add(add(strings, 0x20), mul(i, 0x20)))
                totalLength := add(totalLength, mload(str)) // length of the string
            }

            // Allocate memory for the concatenated string
            result := mload(0x40) // free memory pointer
            let resultData := add(result, 0x20) // offset for length storage
            mstore(0x40, add(resultData, totalLength)) // update free memory pointer

            // Set the length of the result string
            mstore(result, totalLength)

            // Copy each string's content into the result memory
            for {
                let i := 0
            } lt(i, numStrings) {
                i := add(i, 1)
            } {
                let str := mload(add(add(strings, 0x20), mul(i, 0x20)))
                let strLength := mload(str)
                let strData := add(str, 0x20)

                // Copy string data to result memory
                for {
                    let j := 0
                } lt(j, strLength) {
                    j := add(j, 0x20)
                } {
                    mstore(add(resultData, j), mload(add(strData, j)))
                }

                resultData := add(resultData, strLength) // move the pointer
            }
        }
    }

    /// @notice Joins 2-5 strings into one trimming left & right
    /// @param str1 the first part of the string
    /// @param str2 the second part of the string
    /// @return result a concatenated string
    function concatStrings(
        string memory str1,
        string memory str2
    ) internal pure returns (string memory result) {
        // Initiate a fixed length string array
        string[] memory strings = new string[](2);
        // Populate the array
        strings[0] = str1;
        strings[1] = str2;
        // Compute the concatenated string
        result = _concatStrings(strings);
    }

    /// @notice Joins  2-5 strings into one trimming left & right
    /// @param str1 the first part of the string
    /// @param str2 the second part of the string
    /// @param str3 the third part of the string
    /// @return result a concatenated string
    function concatStrings(
        string memory str1,
        string memory str2,
        string memory str3
    ) internal pure returns (string memory result) {
        // Initiate a fixed length string array
        string[] memory strings = new string[](3);
        // Populate the array
        strings[0] = str1;
        strings[1] = str2;
        strings[2] = str3;
        // Compute the concatenated string
        result = _concatStrings(strings);
    }

    /// @notice Joins 2-5 strings into one trimming left & right
    /// @param str1 the first part of the string
    /// @param str2 the second part of the string
    /// @param str3 the third part of the string
    /// @param str4 the fourth part of the string
    /// @return result a concatenated string
    function concatStrings(
        string memory str1,
        string memory str2,
        string memory str3,
        string memory str4
    ) internal pure returns (string memory result) {
        // Initiate a fixed length string array
        string[] memory strings = new string[](4);
        // Populate the array
        strings[0] = str1;
        strings[1] = str2;
        strings[2] = str3;
        strings[3] = str4;
        // Compute the concatenated string
        result = _concatStrings(strings);
    }

    /// @notice Joins 2-5 strings into one trimming left & right
    /// @param str1 the first part of the string
    /// @param str2 the second part of the string
    /// @param str3 the third part of the string
    /// @param str4 the fourth part of the string
    /// @param str5 the fifth part of the string
    /// @return result a concatenated string
    function concatStrings(
        string memory str1,
        string memory str2,
        string memory str3,
        string memory str4,
        string memory str5
    ) internal pure returns (string memory result) {
        // Initiate a fixed length string array
        string[] memory strings = new string[](5);
        // Populate the array
        strings[0] = str1;
        strings[1] = str2;
        strings[2] = str3;
        strings[3] = str4;
        strings[4] = str5;
        // Compute the concatenated string
        result = _concatStrings(strings);
    }

    /// @notice Verifies whether two strings are the same
    /// @param str1 the first string
    /// @param str2 the second string
    /// @return isSame true if `str1` == `str2`, false otherwise
    function equal(
        string memory str1,
        string memory str2
    ) internal pure returns (bool isSame) {
        isSame =
            bytes(str1).length == bytes(str2).length &&
            keccak256(bytes(str1)) == keccak256(bytes(str2));
    }

    /// @notice Reverts with joined 2-5 error parts
    /// @param str1 the first error parameter
    /// @param str2 the second error parameter
    function revertWithParams(
        string memory str1,
        string memory str2
    ) internal pure {
        // Revert with a concatenated error string
        revert(concatStrings(str1, str2));
    }

    /// @notice Reverts with joined 2-5 error parts
    /// @param str1 the first error parameter
    /// @param str2 the second error parameter
    /// @param str3 the third error parameter
    function revertWithParams(
        string memory str1,
        string memory str2,
        string memory str3
    ) internal pure {
        // Revert with a concatenated error string
        revert(concatStrings(str1, str2, str3));
    }

    /// @notice Reverts with joined 2-5 error parts
    /// @param str1 the first error parameter
    /// @param str2 the second error parameter
    /// @param str3 the third error parameter
    /// @param str4 the fourth error parameter
    function revertWithParams(
        string memory str1,
        string memory str2,
        string memory str3,
        string memory str4
    ) internal pure {
        // Revert with a concatenated error string
        revert(concatStrings(str1, str2, str3, str4));
    }

    /// @notice Reverts with joined 5 error parts
    /// @param str1 the first error parameter
    /// @param str2 the second error parameter
    /// @param str3 the third error parameter
    /// @param str4 the fourth error parameter
    /// @param str5 the fifth error parameter
    function revertWithParams(
        string memory str1,
        string memory str2,
        string memory str3,
        string memory str4,
        string memory str5
    ) internal pure {
        // Revert with a concatenated error string
        revert(concatStrings(str1, str2, str3, str4, str5));
    }

    /// @notice Converts an EVM address to a decimal string
    /// @dev Borrowed from OpenZeppelin Strings.sol
    /// @param addr an unsigned integer ∈ {0, (2^160)-1} in hex representation
    function toString(
        address addr
    ) internal pure returns (string memory result) {
        result = toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /// @notice Converts an unsigned integer to a decimal string
    /// @param value an unsigned integer ∈ {0, (2^256)-1}
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = UintMath.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /// @notice Converts a uint256 `value` into a hexadecimal string representation
    /// @dev Modified from OpenZeppelin Strings.sol
    /// @param value an unsigned integer ∈ {0, (2^256)-1}
    /// @return result a hexadecimal string
    function toHexString(
        uint256 value
    ) internal pure returns (string memory result) {
        unchecked {
            result = toHexString(value, UintMath.log256(value) + 1);
        }
    }

    /// @notice Converts a uint256 `value` into a fixed length hexadecimal string representation
    /// @dev Borrowed from OpenZeppelin Strings.sol
    /// @param value an unsigned integer ∈ {0, (2^256)-1}
    /// @param length the expected length of the value
    /// @return result a hexadecimal string
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory result) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            StringsError.revertWithParams(
                "toHexString(value,length) `length`:",
                length.toString(),
                "does not match the `value`:",
                value.toHexString()
            );
        }
        return string(buffer);
    }
}
