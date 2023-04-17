// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Merkle} from "murky/src/Merkle.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import "forge-std/Test.sol";

import {SeedifyLaunchpad} from "../../../contracts/SeedifyFund/SeedifyFundBUSDWithMerkle.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract SeedifyLaunchpadSetUp is Test {
    SeedifyLaunchpad public igo;
    Merkle m;
    MockToken public token = new MockToken("token", "TKN");

    string public name = "igo1";
    uint256 public maxCap = 10_000_000;
    uint256 public saleStart = 60;
    uint256 public saleEnd = 60 * 60;
    uint256 public noOfTiers = 2;
    address public owner = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    uint256 public totalUsers = 10000;
    uint8 public phaseNo = 1;

    // tiers arrays
    uint256[] _tiers;
    uint256[] _maxTierCaps;
    uint256[] _minUserCaps;
    uint256[] _maxUserCaps;
    uint256[] _tierUsers;

    struct User {
        address addr;
        uint256 tier;
    }

    User[] public users;

    bytes32[] public leaves;

    bytes32 public root;

    event UserInvestment(
        address indexed user,
        uint256 amount,
        uint8 indexed phase
    );

    function setUp() public virtual {
        m = new Merkle();
        igo = new SeedifyLaunchpad(
            name,
            maxCap,
            saleStart,
            saleEnd,
            noOfTiers,
            owner,
            address(token),
            // totalUsers,
            phaseNo
        );

        _createUsersAndLeaves();
        _createUpdateTiers();
        _setMerkleRoot();
    }

    function _createUpdateTiers() private {
        // create tiers
        for (uint256 i; i < noOfTiers; ++i) {
            _tiers.push(i + 1);
            _maxTierCaps.push(5_000_000);
            _minUserCaps.push(10);
            _maxUserCaps.push(2_500_000);
            _tierUsers.push(2);
        }
        igo.updateTiers(
            _tiers,
            _maxTierCaps,
            _minUserCaps,
            _maxUserCaps,
            _tierUsers
        );
    }

    function _setMerkleRoot() private {
        root = m.getRoot(leaves);
        igo.updateHash(root);
    }

    function _createUsersAndLeaves() private {
        users.push(User(makeAddr("user1"), 1));
        users.push(User(makeAddr("user2"), 9));
        users.push(User(makeAddr("user3"), 3));
        users.push(User(makeAddr("user4"), 7));

        for (uint256 i; i < users.length; ++i) {
            leaves.push(
                keccak256(abi.encodePacked(users[i].addr, users[i].tier))
            );

            token.mint(users[i].addr, 50_000_000);
        }
    }
}
