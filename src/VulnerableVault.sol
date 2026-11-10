// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/interfaces/IERC20.sol";

/// @title VulnerableVault (practice target — DO NOT DEPLOY)
/// @notice Deliberately vulnerable version of Vault.sol, for practice only.
/// It omits the virtual-shares offset AND the zero-share check, so a
/// first depositor can inflate the share price and steal later deposits.
/// See test/Audit.t.sol for the proof of concept and REPORT-TEMPLATE.md
/// for a filled example report of this exact bug.
/// @dev DELIBERATE FLAWS (for practice):
///   1. convertToShares has no virtual offset: the first deposit of 1 wei
///      mints 1 share, so a large donation makes later deposits round to 0.
///   2. deposit() does not check shares > 0: a deposit that mints 0 shares
///      still takes the caller's tokens, locking them in the vault.
contract VulnerableVault {
    IERC20 public immutable asset;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);
    event Withdraw(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);

    constructor(IERC20 asset_) {
        asset = asset_;
    }

    function totalAssets() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function convertToShares(uint256 assets) public view returns (uint256) {
        if (totalSupply == 0) return assets;
        return assets * totalSupply / totalAssets();
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        if (totalSupply == 0) return shares;
        return shares * totalAssets() / totalSupply;
    }

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        shares = convertToShares(assets);
        // DELIBERATE FLAW: no `require(shares > 0)` here.
        totalSupply += shares;
        balanceOf[receiver] += shares;
        emit Deposit(msg.sender, receiver, assets, shares);
        require(asset.transferFrom(msg.sender, address(this), assets), "transfer failed");
    }

    function withdraw(uint256 shares, address receiver) external returns (uint256 assets) {
        require(balanceOf[msg.sender] >= shares, "insufficient shares");
        assets = convertToAssets(shares);
        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;
        emit Withdraw(msg.sender, receiver, assets, shares);
        require(asset.transfer(receiver, assets), "transfer failed");
    }
}
