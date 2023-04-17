// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {MerkleProof} from "openzeppelin-contracts/utils/cryptography/MerkleProof.sol";
import {Merkle} from "murky/src/Merkle.sol";

import "forge-std/Test.sol";

import {SeedifyLaunchpad} from "../../contracts/SeedifyFund/SeedifyFundBUSDWithMerkle.sol";

contract SeedifyLaunchpad_workaround is SeedifyLaunchpad {
    constructor(
        string memory _name,
        uint256 _maxCap,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _noOfTiers,
        address _owner,
        address _token,
        uint256 _totalUsers,
        uint8 _phaseNo
    )
        SeedifyLaunchpad(
            _name,
            _maxCap,
            _saleStart,
            _saleEnd,
            _noOfTiers,
            _owner,
            _token,
            _totalUsers,
            _phaseNo
        )
    {}

    /// @dev test ` MerkleProof.verify` directly
    function workaround_verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) public pure returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
}

/**
 * @dev Diffentiate between OpenZeppelin MerkleProof and Launchpad MerkleProof
 *      to ensure the implementation is the same as errors can happen when
 *      copy & paste code instead of importing the library.
 */
contract Differential_OZMerkleProof_vs_LaunchpadMerkleProof is Test {
    SeedifyLaunchpad_workaround public igo;
    Merkle m;

    string public name = "igo1";
    uint256 public maxCap = 10000000;
    uint256 public saleStart = 60;
    uint256 public saleEnd = 60 * 60;
    uint256 public noOfTiers = 9;
    address public owner = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    address public token = makeAddr("token");
    uint256 public totalUsers = 10000;
    uint8 public phaseNo = 1;

    function setUp() public {
        m = new Merkle();
        igo = new SeedifyLaunchpad_workaround(
            name,
            maxCap,
            saleStart,
            saleEnd,
            noOfTiers,
            owner,
            token,
            totalUsers,
            phaseNo
        );
    }

    function test_OpenZeppelinProver_SeedifyLaunchpadProver(
        bytes32[] memory _data,
        uint256 node
    ) public {
        vm.assume(_data.length > 1);
        vm.assume(node < _data.length);
        bytes32 root = m.getRoot(_data);

        bytes32[] memory proof = m.getProof(_data, node);
        bytes32 valueToProve = _data[node];

        bool igoVerified = igo.workaround_verify(proof, root, valueToProve);
        bool ozVerified = MerkleProof.verify(proof, root, valueToProve);
        assertTrue(igoVerified == ozVerified);
    }
}
