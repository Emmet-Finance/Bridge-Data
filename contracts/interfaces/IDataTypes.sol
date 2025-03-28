// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

interface IDataTypes {
    struct Token {
        // Slot 0
        address target;
        uint8 tokenDecimals;
        uint8 priceDecimals;
        uint8 symbolLength;
        // Slot 1
        address priceFeed;
        bytes12 symbol; // Max 12 chars
    }

    struct Chain {
        // Slot 0
        uint64 CCTPClaim; // 0 - 7
        uint64 lprelease; // 8 - 15
        uint64 mint; // 16 - 23
        uint64 unlock; // 24 - 31
        // Slot 1
        uint64 swap1; // 32 - 39
        uint64 swap2; // 40 - 47
        uint64 swap3; // 48 - 55
        uint64 swap4; // 56 - 63
        // Slot 2
        uint64 swap5; // 64 - 71
        uint64 swap6; // 72 - 79
        bytes16 name; // Max 16 chars
        // Slot 3
        uint8 tokenDecimals;
        bytes11 flags;
        address priceFeed;
    }

    /// @dev Strategy steps
    /// @param None 0x00 = no action
    /// @param CCTPBurn 0x01 - send
    /// @param CCTPClaim 0x02 - receive
    /// @param Lock 0x03 - send
    /// @param Mint 0x04 - receive
    /// @param Burn 0x05 - send
    /// @param Unlock 0x06 - receive
    /// @param LPStake 0x07 - send
    /// @param LPRelease 0x08 - receive
    /// @param SWAP1 - SWAP6 (0x09 - 0x0e)
    enum Step {
        None,
        // CCTP steps
        CCTPBurn,
        CCTPClaim,
        // Lock and mint steps
        Lock,
        Mint,
        Burn,
        Unlock,
        // Liquidity
        LPStake,
        LPRelease,
        // Swapping steps
        SWAP1,
        SWAP2,
        SWAP3,
        SWAP4,
        SWAP5,
        SWAP6
    }
}