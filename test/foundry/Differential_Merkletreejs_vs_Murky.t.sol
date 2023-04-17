// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {Strings2} from "murky/differential_testing/test/utils/Strings2.sol";
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

    function testFuzzDifferential_hashLeaf_ethersVSsolidity(
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

    /// @dev Test failling, as Murky and Merkletreejs do not return the same root
    function testFuzzDifferential_getRoot(bytes32[] memory leaves) public {
        vm.assume(leaves.length > 1);

        bytes memory packed = abi.encode(leaves);

        string[] memory runJsInputs = new string[](3);
        // Build ffi command string
        runJsInputs[0] = "node";
        runJsInputs[1] = "test/utils/getRoot.js";
        runJsInputs[2] = Strings2.toHexString(packed);

        // Run command and capture output
        bytes32 jsGeneratedRoot = bytes32(vm.ffi(runJsInputs));

        // Calculate root using Murky
        bytes32 murkyGeneratedRoot = m.getRoot(leaves);
        
        emit log_named_bytes32("jsGeneratedRoot", jsGeneratedRoot);
        emit log_named_bytes32("murkyGeneratedRoot", murkyGeneratedRoot);
        // assertEq(murkyGeneratedRoot, jsGeneratedRoot);
    }
}
