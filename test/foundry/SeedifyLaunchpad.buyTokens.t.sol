// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";


import {SeedifyLaunchpadSetUp} from "./setUp/SeedifyLaunchpadSetUp.t.sol";

contract SeedifyLaunchpad_buyTokens is SeedifyLaunchpadSetUp {
    function test_SetUpState() public {
        uint256 tier;

        for (uint256 i; i < noOfTiers; ++i) {
            tier = _tiers[i];
            (
                uint256 maxTierCap,
                uint256 minUserCap,
                uint256 maxUserCap,
                uint256 amountRaised,
                uint256 users_
            ) = igo.tierDetails(tier);

            assertEq(maxTierCap, _maxTierCaps[i], "maxTierCap");
            assertEq(minUserCap, _minUserCaps[i], "minUserCap");
            assertEq(maxUserCap, _maxUserCaps[i], "maxUserCap");
            assertEq(amountRaised, 0, "amountRaised");
            assertEq(users_, _tierUsers[i], "users");
        }
    }

    function test_buyTokens_OneBuyerCheckSavedValues() public {
        uint256 leafIndex = 0;
        bytes32[] memory proof = m.getProof(leaves, leafIndex);
        // bytes32 valueToProve = leaves[leafIndex];

        // user data
        address investor = users[leafIndex].addr;
        uint256 investorTier = users[leafIndex].tier;
        uint256 investedAmount_ = 100_000;
        uint256 oldInvestorBal = token.balanceOf(investor);
        uint256 oldOwnerBal = token.balanceOf(owner);

        vm.warp(saleStart);

        // prank whitelisted user
        vm.startPrank(investor);
        token.increaseAllowance(address(igo), investedAmount_);
        igo.buyTokens(investedAmount_, investorTier, proof);
        /////////////// updated variables ///////////////
        assertEq(igo.totalBUSDReceivedInAllTier(), investedAmount_);
        // tier details
        (, , , uint256 amountRaised, ) = igo.tierDetails(investorTier);
        assertEq(amountRaised, investedAmount_, "amountRaised");
        // user details
        (uint256 tier, uint256 investedAmount) = igo.userDetails(investor);
        assertEq(tier, investorTier, "tier");
        assertEq(investedAmount, investedAmount_, "investedAmount");
        // ERC20 tranfer
        assertEq(
            token.balanceOf(investor),
            oldInvestorBal - investedAmount_,
            "investorBal"
        );
        assertEq(
            token.balanceOf(owner),
            oldOwnerBal + investedAmount_,
            "ownerBal"
        );
    }

    function test_buyTokens_Emits_UserInvestment() public {
        uint256 leafIndex = 0;
        bytes32[] memory proof = m.getProof(leaves, leafIndex);
        // bytes32 valueToProve = leaves[leafIndex];

        // user data
        address investor = users[leafIndex].addr;
        uint256 investorTier = users[leafIndex].tier;
        uint256 investedAmount_ = 100_000;
        uint256 oldInvestorBal = token.balanceOf(investor);
        uint256 oldOwnerBal = token.balanceOf(owner);

        vm.warp(saleStart);

        // prank whitelisted user
        vm.startPrank(investor);
        token.increaseAllowance(address(igo), investedAmount_);
        // verify event emittance
        vm.expectEmit(true, true, false, true);
        emit UserInvestment(investor, investedAmount_, phaseNo);
        bool returned = igo.buyTokens(investedAmount_, investorTier, proof);
        assertEq(returned, true, "returned");
    }
}
