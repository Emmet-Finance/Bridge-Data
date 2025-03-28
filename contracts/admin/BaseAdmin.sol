// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/// @title EmmetAdmin
/// @dev AccessControlUpgradeable integration boilerplate
abstract contract BaseAdmin is
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant CFO_ROLE = keccak256("CFO_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice CFO role bearer
    address public cfo;
    /// @notice Manager role bearer
    address public manager;

    modifier onlyCFO() {
        require(
            hasRole(CFO_ROLE, msg.sender),
            "BaseAdmin: Unauthorized CFO call"
        );
        _;
    }

    modifier onlyManager() {
        require(
            hasRole(MANAGER_ROLE, msg.sender),
            "BaseAdmin: Unauthorized Manager call"
        );
        _;
    }

    event RoleUdated(address old, address updated, string role);
    event Withdraw(string symbol, address recepient);

    /// @notice Contract initializer
    /// @param cfo_ ROLE: Chief Financial Officer
    /// @param manager_ ROLE: the contract setter
    function _admin_init(address cfo_, address manager_) public initializer {
        _expectNonZeroAddress(cfo_);
        _expectNonZeroAddress(manager_);

        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CFO_ROLE, cfo_);
        _grantRole(MANAGER_ROLE, manager_);

        cfo = cfo_;
        manager = manager_;
    }

    /// @notice Accepts ETH
    receive() external payable {}

    /// @dev event mitigation
    function pause() external whenNotPaused onlyRole(MANAGER_ROLE) {
        _pause();
    }

    /// @dev unlocking after an event is mitigated
    function unpause() external whenPaused onlyRole(MANAGER_ROLE) {
        _unpause();
    }

    /// @notice Replaces the CFO
    /// @param candidate the new role bearer
    function updateCFO(address candidate) external onlyManager {
        _expectNonZeroAddress(candidate);

        emit RoleUdated(cfo, candidate, "CFO");

        _revokeRole(CFO_ROLE, cfo);
        cfo = candidate;
        _grantRole(CFO_ROLE, cfo);
    }

    /// @notice Replaces the Manager
    /// @param candidate the new role bearer
    function updateManager(address candidate) external onlyManager {
        _expectNonZeroAddress(candidate);

        emit RoleUdated(manager, candidate, "Manager");

        _revokeRole(MANAGER_ROLE, manager);
        manager = candidate;
        _grantRole(MANAGER_ROLE, manager);
    }

    /// @notice Collects the native coins if any
    function coinWithdraw() external onlyRole(CFO_ROLE) {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}(
            "Coin Withdraw"
        );
        if (!success) {
            revert("Coin withdraw failed");
        }
        emit Withdraw("Native Coin", msg.sender);
    }

    /// @dev AccessControlUpgradeable required
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    /// @dev Verifies the address is not zero
    function _expectNonZeroAddress(address candidate) private pure {
        require(candidate != address(0), "BaseAdmin: address zero provided");
    }
}
