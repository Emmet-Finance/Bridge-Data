// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {IDataTypes} from "../interfaces/IDataTypes.sol";

library Strategies {
    struct Steps {
        bytes32 foreign;
        bytes32 incoming;
        bytes32 local;
    }

    struct Storage {
        mapping(uint256 chainId => mapping(string fromToken => mapping(string toToken => Steps))) steps;
    }

    function getForeignStrategies(
        Storage storage self, 
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) internal view returns(uint8[] memory steps){
        return _unpack(self.steps[chainId][fromToken][toToken].foreign);
    }

    function getIncomingStrategies(
        Storage storage self, 
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) internal view returns(uint8[] memory steps){
        return _unpack(self.steps[chainId][fromToken][toToken].incoming);
    }

    function getLocalStrategies(
        Storage storage self, 
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) internal view returns(uint8[] memory steps){
        return _unpack(self.steps[chainId][fromToken][toToken].local);
    }

    function getStrategies(
        Storage storage self, 
        uint256 chainId,
        string memory fromToken,
        string memory toToken
    ) internal view returns(
        uint8[] memory foreign,
        uint8[] memory incoming,
        uint8[] memory local
    ){
        foreign = getForeignStrategies(self, chainId, fromToken, toToken);
        incoming = getIncomingStrategies(self, chainId, fromToken, toToken);
        local = getLocalStrategies(self, chainId, fromToken, toToken);
    }

    function setStrategies(
        Storage storage self, 
        uint256 chainId,
        string memory fromToken,
        string memory toToken,
        IDataTypes.Step[] memory foreign,
        IDataTypes.Step[] memory incoming,
        IDataTypes.Step[] memory local
    ) internal {
        self.steps[chainId][fromToken][toToken] = Steps({
            foreign: _pack(foreign),
            incoming: _pack(incoming),
            local: _pack(local)
        });
    }   

    function _pack(IDataTypes.Step[] memory steps) private pure returns(bytes32 packedData){
        uint8 length = uint8(steps.length);
        require(length <= 31, "Too many steps"); // Ensure it fits within 31 bytes

        bytes32 temp;
        for (uint8 i = 0; i < length; i++) {
            temp |= bytes32(uint256(uint8(steps[i])) << (248 - (i * 8)));
        }

        // Store length in the first byte
        packedData = temp | bytes32(uint256(length));
    }

    function _unpack(bytes32 packedData) private pure returns (uint8[] memory steps) {
        uint8 length = uint8(uint256(packedData)); // Extract the first byte for length
        steps = new uint8[](length);

        for (uint8 i = 0; i < length; i++) {
            steps[i] = uint8(uint256(packedData >> (248 - (i * 8))));
        }
    }
}
