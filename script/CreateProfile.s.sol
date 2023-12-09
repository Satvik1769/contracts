// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
// import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { ProfileFactory } from "../src/ProfileFactory.sol";
import { HelpersConfig } from "./helpers/HelpersConfig.s.sol";

contract CreateProfile is Script {

        string uri = "https://github.com/nightfallsh4";
    string name = "0xnightfall.eth";
    string symbol = "sh4";

    function run()  external returns (address){
        ProfileFactory factory = ProfileFactory(0x5d9c4b42022D50629FB86fDB993d1d95f550B3B0);
        vm.startBroadcast();
        address profileAddress = factory.createProfile(name,symbol,uri);
        vm.stopBroadcast();
        return profileAddress;
    }
}