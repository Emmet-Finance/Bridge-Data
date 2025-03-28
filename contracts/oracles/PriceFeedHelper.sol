// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Strings} from "../libs/Strings.sol";
import {IPriceFeedInterface} from "./IPriceFeedInterface.sol";

library PriceFeedHelper {
    using Strings for address;
    using Strings for string;
    using Strings for uint256;

    string private constant PriceFeedHelperError = "PriceFeedHelperError:";
    string private constant UnsupportedLatestAnswer =
        ". unsupported latestAnswer.";
    string private constant UnsupportedDecimals = ". unsupported decimals.";
    string private constant UnsupportedLatestRoundData =
        ". unsupported latestRoundData.";

    /// @dev Check whether the required functions are callable
    /// @dev reverts if at least one of the functions is not callable
    /// @param feed the address of the potential price feed
    function verifyPriceFeed(address feed) internal view {
        IPriceFeedInterface priceFeed = IPriceFeedInterface(feed);

        string memory errorMessage;

        uint256 counter;

        try priceFeed.latestAnswer() returns (int256) {
            // supports `latestAnswer`
        } catch {
            errorMessage = PriceFeedHelperError.concatStrings(
                (++counter).toString(),
                UnsupportedLatestAnswer
            );
        }

        try priceFeed.decimals() returns (uint8) {
            // supports `decimals`
        } catch {
            if (bytes(errorMessage).length > 0) {
                errorMessage = errorMessage.concatStrings(
                    (++counter).toString(),
                    UnsupportedDecimals
                );
            } else {
                errorMessage = PriceFeedHelperError.concatStrings(
                    (++counter).toString(),
                    UnsupportedDecimals
                );
            }
        }

        try priceFeed.latestRoundData() returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        ) {
            // supports `latestRoundData`
        } catch {
            if (bytes(errorMessage).length > 0) {
                errorMessage = errorMessage.concatStrings(
                    (++counter).toString(),
                    UnsupportedLatestRoundData
                );
            } else {
                errorMessage = PriceFeedHelperError.concatStrings(
                    (++counter).toString(),
                    UnsupportedLatestRoundData
                );
            }
        }

        if (bytes(errorMessage).length > 0) {
            revert(errorMessage.concatStrings(feed.toString()));
        }
    }

    /// @notice Converts `amountA` to `resultB`
    /// @param amountA the token amount to be converted
    /// @param aFeed the address of the `amountA` priceFeed
    /// @param bFeed the address of the `convertedB` priceFeed
    /// @param decimalsA the number of decimal points of token A
    /// @param decimalsB the number of decimal points of token B
    /// @return resultB the amount of token A in token B
    function convert(
        uint256 amountA,
        address aFeed,
        address bFeed,
        uint8 decimalsA,
        uint8 decimalsB
    ) internal view returns (uint256 resultB) {
        // Get the prices
        uint256 aPrice = uint256(IPriceFeedInterface(aFeed).latestAnswer());
        uint256 bPrice = uint256(IPriceFeedInterface(bFeed).latestAnswer());

        // We cannot convert if any of the prices is zero
        if (aPrice == 0 || bPrice == 0) return 0;

        // Get the decimals of the prices
        uint256 aDecimals = 10 **
            (IPriceFeedInterface(aFeed).decimals() + decimalsA);
        uint256 bDecimals = 10 **
            (IPriceFeedInterface(bFeed).decimals() + decimalsB);

        bool isBGreater = bDecimals > aDecimals;

        uint256 difference = isBGreater
            ? bDecimals - aDecimals
            : aDecimals - bDecimals;

        uint256 aPrepared = amountA * aPrice;

        if (difference == 0) {
            resultB = aPrepared / bPrice;
        } else if (isBGreater) {
            resultB = (aPrepared * difference) / bPrice;
        } else {
            resultB = aPrepared / difference / bPrice;
        }
    }
}
