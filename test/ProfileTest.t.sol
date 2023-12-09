// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { Deploy } from "script/Deploy.s.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { ProfileFactory } from "../src/ProfileFactory.sol";
import { ProfileNft } from "../src/ProfileNft.sol";

contract ProfileTest is Test, HelpersConfig, Deploy {
    ChainConfig config;
    ProfileFactory factory;
    ProfileNft profile;

    event ProfileMinted(address indexed profileAddress, address indexed owner, string indexed uri);

    address user1 = vm.addr(1);
    address user2 = vm.addr(2);

    string uri = "https://github.com/nightfallsh4";
    string name = "0xnightfall.eth";
    string symbol = "sh4";

    function setUp() external {
        // Getting the config from helpersConfig for the chain
        config = getConfig();

        // Initializing the Deply Scripts
        Deploy deploy = new Deploy();

        address _factory = deploy.deploy();
        factory = ProfileFactory(_factory);
    }

    function testMakeProfile() external {
        hoax(user1, 10 ether);
        vm.expectEmit(false, false, true, false);
        emit ProfileMinted(address(267), address(this), uri);
        address _profile = factory.createProfile(name, symbol, uri);
        profile = ProfileNft(_profile);
        address owner = profile.owner();
        assertEq(user1, owner);
    }

    function makeProfile() public returns (ProfileNft) {
        address _profile = factory.createProfile(name, symbol, uri);
        return ProfileNft(_profile);
    }

    function testMint() external {
        hoax(user1, 10 ether);
        ProfileNft profile1 = makeProfile();
        hoax(user2, 10 ether);
        ProfileNft profile2 = makeProfile();

        bytes32 digest = keccak256(abi.encode(address(profile1)));
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);
        bytes memory user2Signature = abi.encodePacked(r2, s2, v2);
        hoax(user1);
        profile1.mint(address(profile2), user2Signature, 0);
    }
}
