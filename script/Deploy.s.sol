// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
// import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";

contract DeployVault is Script {
    address entryPoint = address(6);

    function run() external returns (address, address, address, address) {
        uint256 privateKey;
        if (chainId == 11_155_111) {
            privateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        } else {
            privateKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(privateKey);
        (address registry, address guardian, address tokenShieldNft, address vaultImpl) = deploy();
        vm.stopBroadcast();
        writeLatestFile(registry, guardian, tokenShieldNft, vaultImpl);
        return (registry, guardian, tokenShieldNft, vaultImpl);
    }
}