// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {EmmetAdmin} from "../admin/EmmetAdmin.sol";
import {IEmmetPriceFeedAdmin} from "./IEmmetPriceFeedAdmin.sol";
import {IPriceFeedInterface} from "./IPriceFeedInterface.sol";

contract EmmetPriceFeed is
    EmmetAdmin,
    IEmmetPriceFeedAdmin,
    IPriceFeedInterface
{
    /// @dev the price fractional digits
    uint8 private _decimals;
    /// @dev the index of the observation round
    uint80 private _roundId;
    /// @dev the latesd observed price
    int256 public latestAnswer;
    /// @dev the feed starting block.timestamp
    uint256 public startedAt;
    /// @dev the block.timestamp when last updated
    uint256 private _updatedAt;
    /// @dev number of oracles in the round
    uint80 private _answeredInRound;
    /// @dev Human-readable price-feed description
    string public description;

    // Reserve 20 storage slots for potential future upgrades
    uint256[20] private __gap;

    event PriceUpdated(
        int256 oldPrice,
        int256 newPrice,
        uint80 answeredInRound
    );

    error EmmetPriceFeedError(string reason);

    /// @notice Initializes the contract with decimals, description, manager, and CFO
    /// @param decimals_ The price fractional digits
    /// @param description_ Human-readable price-feed description
    /// @param manager_ Address of the manager with MANAGER_ROLE
    /// @param cfo_ Address of the CFO with CFO_ROLE
    function initializePriceFeed(
        uint8 decimals_, 
        string memory description_,
        address manager_,
        address cfo_
    ) external initializer {
        _decimals = decimals_;
        description = description_;
        startedAt = block.timestamp;

        // Call the initializer for EmmetAdmin
        EmmetAdmin.initialize(cfo_, manager_);
    }

    // ====================== IPriceFeedInterface =======================

    /// @inheritdoc IPriceFeedInterface
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /// @inheritdoc IPriceFeedInterface
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 _startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        roundId = _roundId;
        answer = latestAnswer;
        _startedAt = startedAt;
        updatedAt = _updatedAt;
        answeredInRound = _answeredInRound;
    }

    // ====================== IEmmetPriceFeedAdmin =======================

    /// @inheritdoc IEmmetPriceFeedAdmin
    function updateTokenPrice(
        int256 newPrice_,
        uint80 answeredInRound_
    ) external onlyRole(MANAGER_ROLE) {
        if (answeredInRound_ == 0) {
            revert EmmetPriceFeedError(
                "Insufficient number of answers in round."
            );
        }
        _roundId++;
        _updatedAt = block.timestamp;
        _answeredInRound = answeredInRound_;
        if (newPrice_ != latestAnswer) {
            int256 oldPrice = latestAnswer;
            latestAnswer = newPrice_;
            emit PriceUpdated(oldPrice, latestAnswer, answeredInRound_);
        }
    }
}
