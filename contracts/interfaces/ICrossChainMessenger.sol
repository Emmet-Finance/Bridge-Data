// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ICrossChainMessenger {
    /// @dev Solves `Stack too deep.` in receiveMsg
    /// @param txHash the cross-chain message hash
    /// @param nonce the unique origin outgoing transaction index
    /// @param value the number of destination tokens (if payable)
    /// @param timestamp the starting blcok timestamp
    /// @param fromChainId an EIP-155 origin chain ID
    /// @param toChainId an EIP-155 origin chain ID, should match with the local ID
    /// @param receiver the contract to receive the call
    /// @param sender the cross-chain TX initiator & payer
    /// @param data an abi encoded with signature call data
    /// @param relayers an array of trusted signers & relayers
    /// @param signatures an array of the relayers' signatures
    struct ReceiveParams {
        bytes32 txHash;
        uint256 nonce;
        uint256 value;
        uint256 timestamp;
        uint128 fromChainId;
        uint128 toChainId;
        address receiver;
        string sender;
        bytes data;
        address[] relayers;
        bytes[] signatures;
    }

    /// @notice Calculates the amount to reimburse
    function estimateFee() external view returns (uint256);

    /// @notice Returns the target contract as a string
    /// @param sender the address of the mapped sender
    /// @param chainId the destination chain iddentifier
    function getMappedContract(
        address sender,
        uint256 chainId
    ) external view returns (string memory);

    /// @notice Fetches an incoming transaction data
    /// @param txHash a CCM marker
    /// @return blockNumber the number of the transaction block
    function getReceivedMessage(
        bytes32 txHash
    ) external view returns (uint256 blockNumber);

    /// @notice Processes an outgoing message
    /// @param value the number of destination tokens (if payable)
    /// @param toChainId an EIP-155 destination chain ID
    /// @param sender the transaction initiator
    /// @param receiver the address of the receipient
    /// @param data the bytes encoded call parameters
    /// @param selector the target function selector
    /// @return txHash the CCM hash marker
    function sendMsg(
        uint256 value,
        uint128 toChainId,
        address sender,
        string memory receiver,
        bytes memory data,
        bytes4 selector
    ) external payable returns (bytes32 txHash);
}
