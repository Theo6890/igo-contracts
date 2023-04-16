// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {Merkle} from "murky/Merkle.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";

import "forge-std/Test.sol";

/**
 * @dev Test `buyTokens` function to ensure it works as expected, especiqlly
 *      the usage Merkle Root to whitelist wallets.
 */
contract Differential_Merkletreejs_vs_Murky is Test {
    Merkle m;

    function setUp() public {
        m = new Merkle();
    }

    function testDifferential_hashLeaf_ethersVSsolidity(
        address participant,
        uint8 tier
    ) public {
        string[] memory cmd = new string[](4);
        cmd[0] = "node";
        cmd[1] = "test/utils/hashLeaf.js";
        cmd[2] = Strings.toHexString(participant);
        cmd[3] = Strings.toString(tier);
        bytes memory res = vm.ffi(cmd);

        bytes32 ethersLeafHash = bytes32(res);
        bytes32 solidityLeafHash = keccak256(
            abi.encodePacked(participant, tier)
        );

        assertEq(ethersLeafHash, solidityLeafHash);
    }
}
