// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {IDataTypes} from "./interfaces/IDataTypes.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IEmmetDataV2 is IERC165, IDataTypes {
    /// @notice Fetches a chain settings
    /// @param chainId an EIP-155-like identifier
    function getChain(
        uint16 chainId
    ) external view returns (Chain memory chain);

    function getForeignFee(
        uint16 foreignChainId,
        uint8 op
    ) external view returns (uint256);

    /// @notice Fetches an array of strategies
    /// @param chainId foreign chain identifier
    /// @param fromToken the deposited token symbol
    /// @param toToken the expected token symbol
    function getForeignStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) external view returns(uint8[] memory);

    /// @notice Fetches an array of strategies
    /// @param chainId foreign chain identifier
    /// @param fromToken the deposited token symbol
    /// @param toToken the expected token symbol
    function getIncomingStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) external view returns(uint8[] memory);

    /// @notice Fetches an array of strategies
    /// @param chainId foreign chain identifier
    /// @param fromToken the deposited token symbol
    /// @param toToken the expected token symbol
    function getLocalStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) external view returns(uint8[] memory);

    function getNativeCoinName() external view returns(string memory);

    /// @notice Fetches an array of strategies
    /// @param chainId foreign chain identifier
    /// @param fromToken the deposited token symbol
    /// @param toToken the expected token symbol
    function getStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) external view returns(
        uint8[] memory foreign,
        uint8[] memory incoming,
        uint8[] memory local
    );

    function getToken(
        string memory symbol
    ) external view returns (Token memory token);

    function estimateForeignFees(
        uint256 toChainId,
        string memory fromToken,
        string memory toToken
    ) external view returns (uint256 fee);

    function isChainSupported(uint16 chainId) external view returns (bool);

    function isTokenSupported(
        string memory symbol
    ) external view returns (bool);
}