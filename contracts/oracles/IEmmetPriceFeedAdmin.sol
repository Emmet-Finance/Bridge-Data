// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

interface IEmmetPriceFeedAdmin {
    /// @notice Updates the token price
    /// @dev Requires: onlyRole(MANAGER_ROLE)
    /// @dev Reverts if answeredInRound_ == 0
    /// @param newPrice_ the new price
    /// @param answeredInRound_ the number of oracles
    function updateTokenPrice(
        int256 newPrice_,
        uint80 answeredInRound_
    ) external;
}
