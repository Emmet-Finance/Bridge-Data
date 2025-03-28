// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title UintMath
/// @notice Minimal required math-related logic
/// @dev Extracted & modified from @OpenZeppelin/contracts/math/
library UintMath {
    /// @notice Computes log in base 10
    /// @param value an unsigned integer ∈ {0, (2^256)-1}
    /// @return result a truncated(rounded towards zero) log in base 10
    function log10(uint256 value) internal pure returns (uint256 result) {
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
    }

    /// @notice Computes a log in base 256
    /// @param value an unsigned integer ∈ {0, (2^256)-1}
    /// @return result a truncated(rounded towards zero) log in base 256
    function log256(uint256 value) internal pure returns (uint256 result) {
        uint256 isGreaterThan;
        unchecked {
            isGreaterThan = toUint(value > (1 << 128) - 1);
            value >>= isGreaterThan * 128;
            result += isGreaterThan * 16;

            isGreaterThan = toUint(value > (1 << 64) - 1);
            value >>= isGreaterThan * 64;
            result += isGreaterThan * 8;

            isGreaterThan = toUint(value > (1 << 32) - 1);
            value >>= isGreaterThan * 32;
            result += isGreaterThan * 4;

            isGreaterThan = toUint(value > (1 << 16) - 1);
            value >>= isGreaterThan * 16;
            result += isGreaterThan * 2;

            result += toUint(value > (1 << 8) - 1);
        }
    }

    /// @notice Casts a bool ∈ {false, true} to uint256 ∈ {0, 1}
    /// @param value a boolean expression ∈ {false, true}
    /// @return uInt an unsigned integer ∈ {0, 1}
    function toUint(bool value) internal pure returns (uint256 uInt) {
        assembly ("memory-safe") {
            uInt := iszero(iszero(value))
        }
    }
}
