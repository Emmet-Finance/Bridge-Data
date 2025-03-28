// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {BridgeFees} from "./libs/BridgeFees.sol";
import {IDataTypes} from "./interfaces/IDataTypes.sol";
import {IEmmetDataV2} from "./IEmmetDataV2.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Strategies} from "./libs/Strategies.sol";

contract EmmetDataV2 is IEmmetDataV2, ERC165 {
    using BridgeFees for BridgeFees.Storage;
    using Strategies for Strategies.Storage;

    bytes32 public immutable ADMIN_ROLE = keccak256("ADMIN_ROLE");

    string public nativeTokenName;
    BridgeFees.Storage private mem;
    Strategies.Storage private strategies;
    mapping(address bearer => bytes32 role) public roles;

    modifier onlyAdmin() {
        require(roles[msg.sender] == ADMIN_ROLE);
        _;
    }

    constructor(uint16 localChainId, string memory _nativeTokenName) {
        require(localChainId > 0, "Unsupported chain Id");
        require(bytes(_nativeTokenName).length > 0, "Empty native token name");
        mem.localChainId = localChainId;
        roles[msg.sender] = bytes32(ADMIN_ROLE);
        nativeTokenName = _nativeTokenName;
    }

    // S E T T E R S

    function setChain(uint16 chainId, Chain memory chain) external onlyAdmin {
        mem.setChain(chainId, chain);
    }

    function setChains(
        uint16[] memory chainIds,
        Chain[] memory chains
    ) external onlyAdmin {
        mem.setChains(chainIds, chains);
    }

    function setStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken,
        IDataTypes.Step[] memory foreign,
        IDataTypes.Step[] memory incoming,
        IDataTypes.Step[] memory local
    )external onlyAdmin {
        require(bytes(fromToken).length > 0, "Empty from token");
        require(bytes(toToken).length > 0, "Empty to token");
        strategies.setStrategies(chainId, fromToken, toToken, foreign, incoming, local);
    }

    function setToken(
        string memory symbol,
        address target,
        uint8 tokenDecimals,
        uint8 priceDecimals,
        address priceFeed
    ) external onlyAdmin {
        mem.setToken(symbol, target, tokenDecimals, priceDecimals, priceFeed);
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        roles[msg.sender] = bytes32(0);
        roles[newAdmin] = bytes32(ADMIN_ROLE);
    }

    // G E T T E R S

    /// @inheritdoc IEmmetDataV2
    function getChain(
        uint16 chainId
    ) external view returns (IDataTypes.Chain memory chain) {
        chain = mem.chains[chainId];
    }

    /// @inheritdoc IEmmetDataV2
    function getForeignFee(
        uint16 foreignChainId,
        uint8 op
    ) external view returns (uint256) {
        return BridgeFees._getForeignFee(mem, foreignChainId, op);
    }

    /// @inheritdoc IEmmetDataV2
    function getForeignStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) public view returns (uint8[] memory) {
        return strategies.getForeignStrategies(chainId, fromToken, toToken);
    }

    /// @inheritdoc IEmmetDataV2
    function getIncomingStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) external view returns (uint8[] memory) {
        return strategies.getIncomingStrategies(chainId, fromToken, toToken);
    }

    /// @inheritdoc IEmmetDataV2
    function getLocalStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) external view returns (uint8[] memory) {
        return strategies.getLocalStrategies(chainId, fromToken, toToken);
    }

    /// @inheritdoc IEmmetDataV2
    function getNativeCoinName() external view returns (string memory) {
        return nativeTokenName;
    }

    function getStrategies(
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    )
        external
        view
        returns (
            uint8[] memory foreign,
            uint8[] memory incoming,
            uint8[] memory local
        )
    {
        return strategies.getStrategies(chainId, fromToken, toToken);
    }

    /// @inheritdoc IEmmetDataV2
    function getToken(
        string memory symbol
    ) external view returns (IDataTypes.Token memory token) {
        token = mem.tokens[symbol];
    }

    /// @inheritdoc IEmmetDataV2
    function estimateForeignFees(
        uint256 toChainId,
        string memory fromToken,
        string memory toToken
    ) external view returns (uint256 fee) {
        uint8[] memory foreign = getForeignStrategies(toChainId, fromToken, toToken);
        if(foreign.length == 0) revert("EmmetDataV2: Fee estimation failed, foreign strategy not set");
        fee = mem.estimateTargetFee(uint16(toChainId), foreign);
    }

    /// @inheritdoc IEmmetDataV2
    function isChainSupported(uint16 chainId) external view returns (bool) {
        return mem.isChainSupported(chainId);
    }

    /// @inheritdoc IEmmetDataV2
    function isTokenSupported(
        string memory symbol
    ) external view returns (bool) {
        return mem.isTokenSupported(symbol);
    }

    /// @inheritdoc IERC165
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, IERC165) returns (bool) {
        return
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IEmmetDataV2).interfaceId;
    }
}
