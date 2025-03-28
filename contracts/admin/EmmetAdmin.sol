// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {ICrossChainMessenger} from "../interfaces/ICrossChainMessenger.sol";
import {Strings} from "../libs/Strings.sol";

/// @title EmmetAdmin
/// @dev AccessControlUpgradeable integration boilerplate
abstract contract EmmetAdmin is
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Strings for string;
    using Strings for address;

    bytes32 public constant CFO_ROLE = keccak256("CFO_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
    string private constant EmmetAdminError = "Emmet Admin Error:";

    // Cross-Chain-Messenger address
    ICrossChainMessenger public ccm;

    /// @dev limits the function caller to CCM
    modifier onlyCCM() {
        if(address(ccm) == address(0)) revert("Cross-Chain Messaging Not Set.");
        require(msg.sender == address(ccm), "Unauthorized call.");
        _;
    }

    event CCMUpdated(address newCCM);

    /// @notice Contract initializer
    /// @param cfo_ ROLE: Chief Financial Officer
    /// @param manager_ ROLE: the contract setter
    function initialize(address cfo_, address manager_) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CFO_ROLE, cfo_);
        _grantRole(MANAGER_ROLE, manager_);
    }

    /// @dev AccessControlUpgradeable required
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    /// @dev event mitigation
    function pause() external whenNotPaused onlyRole(MANAGER_ROLE){
        _pause();
    }

    /// @dev unlocking after an event is mitigated
    function unpause() external whenPaused onlyRole(MANAGER_ROLE) {
        _unpause();
    }

    /// @notice Updates the Cross-Chain Messaging contract address
    /// @dev Emits CCMUpdated(address)
    /// @param ccm_ the new contract address
    function updateCCM(
        address ccm_
    ) external onlyRole(MANAGER_ROLE) whenNotPaused {
        if (ccm_ != address(0)) {
            if (ccm_.code.length == 0) {
                EmmetAdminError.revertWithParams(
                    "provided ccm_ is not a contract."
                );
            }

            ccm = ICrossChainMessenger(ccm_);

            emit CCMUpdated(ccm_);
        }
    }
}
