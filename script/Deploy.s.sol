// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
// import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { ProfileFactory } from "../src/ProfileFactory.sol";
import { HelpersConfig } from "./helpers/HelpersConfig.s.sol";

contract Deploy is Script {
    address entryPoint = address(6);

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        // if (chainId == 11_155_111) {
        //     privateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        // } else {
        //     privateKey = vm.envUint("PRIVATE_KEY");
        // }

        vm.startBroadcast(privateKey);
        address factory = deploy();

        vm.stopBroadcast();
        // return factory;
    }

    function deploy() public returns (address) {
        ProfileFactory factory = new ProfileFactory();
        return address(factory);
    }
}
