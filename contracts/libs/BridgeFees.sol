// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPriceFeedInterface} from "../interfaces/IPriceFeedInterface.sol";
import {IDataTypes} from "../interfaces/IDataTypes.sol";
// import {console} from "hardhat/console.sol";

library BridgeFees {

    struct Storage {
        uint16 localChainId;
        mapping(uint16 chainId => IDataTypes.Chain chain) chains;
        mapping(string symbol => IDataTypes.Token token) tokens;
    }

    // S E T T E R S

    function setChain(
        Storage storage self,
        uint16 chainId,
        IDataTypes.Chain memory chain
    ) internal {
        self.chains[chainId] = IDataTypes.Chain({
            CCTPClaim: chain.CCTPClaim,
            lprelease: chain.lprelease,
            mint: chain.mint,
            unlock: chain.unlock,
            swap1: chain.swap1,
            swap2: chain.swap2,
            swap3: chain.swap3,
            swap4: chain.swap4,
            swap5: chain.swap5,
            swap6: chain.swap6,
            name: chain.name,
            tokenDecimals: chain.tokenDecimals,
            flags: chain.flags,
            priceFeed: chain.priceFeed
        });
    }

    function setChains(
        Storage storage self,
        uint16[] memory chainIds,
        IDataTypes.Chain[] memory chains
    ) internal {
        uint256 length = chainIds.length;
        require(
            length == chains.length,
            "chainIds and chains lengths don't match"
        );
        for (uint256 i = 0; i < length; i++) {
            self.chains[chainIds[i]] = chains[i];
        }
    }

    function setToken(
        Storage storage self,
        string memory symbol,
        address target,
        uint8 tokenDecimals,
        uint8 priceDecimals,
        address priceFeed
    ) internal {
        require(bytes(symbol).length <= 10, "Symbol too long");
        self.tokens[symbol] = IDataTypes.Token({
            target: target,
            tokenDecimals: tokenDecimals,
            priceDecimals: priceDecimals,
            priceFeed: priceFeed,
            symbolLength: uint8(bytes(symbol).length),
            symbol: bytes10(bytes(symbol))
        });
    }

    // G E T T E R S

    function isChainSupported(
        Storage storage self,
        uint16 chainId
    ) internal view returns (bool) {
        return self.chains[chainId].priceFeed != address(0);
    }

    function isTokenSupported(
        Storage storage self,
        string memory symbol
    ) internal view returns (bool) {
        IDataTypes.Token memory t = self.tokens[symbol];
        return t.target != address(0) && t.priceFeed != address(0);
    }

    function estimateTargetFee(
        Storage storage self,
        uint16 foreignChainId,
        uint8[] memory op
    ) internal view returns (uint256) {
        // Read the chains
        address foreignChainPriceFeed = self.chains[foreignChainId].priceFeed;
        address localChainPriceFeed = self.chains[self.localChainId].priceFeed;

        if (foreignChainPriceFeed == address(0)) {
            revert("Unsupported foreign chain");
        }

        if (localChainPriceFeed == address(0)) {
            revert("Local chain not configured");
        }

        // Read the operation cost
        uint64 foreignFee = 0;
        for (uint i = 0; i < op.length; i++) {
            foreignFee += _getForeignFee(self, foreignChainId, op[i]);
        }

        (, int256 foreignPrice, , , ) = IPriceFeedInterface(
            foreignChainPriceFeed
        ).latestRoundData();
        (, int256 localPrice, , , ) = IPriceFeedInterface(localChainPriceFeed)
            .latestRoundData();

        if (foreignPrice <= 0) revert("Invalid foreign coin price");
        if (localPrice <= 0) revert("Invalid local coin price");

        // Convert the fee from foreign gas token to local gas token
        // return (uint256(foreignFee) * foreignPriceScaled) / localPriceScaled;
        return (uint256(foreignFee) * uint256(foreignPrice)) / uint256(localPrice);
    }

    function _getForeignFee(
        Storage storage self,
        uint16 chainId,
        uint8 op
    ) internal view returns (uint64 fee) {

        if (op == 0x02) return self.chains[chainId].CCTPClaim;
        if (op == 0x08) return self.chains[chainId].lprelease;
        if (op == 0x04) return self.chains[chainId].mint;
        if (op == 0x06) return self.chains[chainId].unlock;
        if (op == 0x09) return self.chains[chainId].swap1;
        if (op == 0x0A) return self.chains[chainId].swap2;
        if (op == 0x0B) return self.chains[chainId].swap3;
        if (op == 0x0C) return self.chains[chainId].swap4;
        if (op == 0x0D) return self.chains[chainId].swap5;
        if (op == 0x0E) return self.chains[chainId].swap6;

        revert("BridgeFees: Invalid operation");
    }

    // P R I V A T E

    function scalePriceTo18Decimals(
        int256 price,
        uint8 priceDecimals
    ) private pure returns (int256) {
        require(price > 0, "Price must be positive");

        if (priceDecimals > 18) {
            uint256 divisor = 10 ** (priceDecimals - 18);
            return
                price >= int256(divisor)
                    ? int256(price) / int256(divisor)
                    : int256(1); // Ensure min value is `1`
        } else {
            return int256(price) * int256(10 ** (18 - priceDecimals));
        }
    }
}
