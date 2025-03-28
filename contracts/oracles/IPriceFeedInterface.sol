// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/// @title IPriceFeedInterface
/// @dev Compatible with https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol
interface IPriceFeedInterface {
    /// @notice Fetches the latest round price
    /// @return the latest price
    function latestAnswer() external view returns (int256);

    /// @notice Fetches price decimals
    /// @return decimals of the token price
    function decimals() external view returns (uint8);

    /// @notice Fetches the latest round data
    /// @return roundId the round index
    /// @param answer the latest USD price
    /// @param _startedAt the contract deployment block timestamp
    /// @param updatedAt the last update timestamp
    /// @param answeredInRound the number of participating oracles
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 _startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}
