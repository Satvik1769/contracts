// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";

contract HelpersConfig is Script {
    struct ChainConfig {
        address router;
        address linkAddress;
    }

    // ChainConfig private config;
    uint256 public chainId;

    constructor() {
        chainId = block.chainid;
    }

    function getConfig() public view returns (ChainConfig memory) {
        ChainConfig memory config;
        if (chainId == 31_337) {
            config = getAnvilConfig();
        }
        if (chainId == 84_532) {
            config = getBaseConfig();
        }
        if (chainId == 534_351) {
            config = getScrollConfig();
        }
        if (chainId == 421_614) {
            config = getArbitrumConfig();
        }

        return config;
    }

    function getAnvilConfig() internal pure returns (ChainConfig memory) {
        return ChainConfig({ router: address(0), linkAddress: address(1) });
    }

    function getScrollConfig() internal pure returns (ChainConfig memory) {
        // address adminAddress = vm.envAddress("SEPOLIA_ADMIN_ADDRESS");
        // address guardSigner = vm.envAddress("SEPOLIA_GUARDIAN_SIGNER");
        // address guardSetter = vm.envAddress("SEPOLIA_GUARDIAN_SETTER");
        return ChainConfig({ router: address(0), linkAddress: address(1) });
    }

    function getBaseConfig() internal view returns (ChainConfig memory) {
        // address adminAddress = vm.envAddress("SEPOLIA_ADMIN_ADDRESS");
        // address guardSigner = vm.envAddress("SEPOLIA_GUARDIAN_SIGNER");
        // address guardSetter = vm.envAddress("SEPOLIA_GUARDIAN_SETTER");
        return ChainConfig({ router: address(0), linkAddress: address(1) });
    }

    function getArbitrumConfig() internal view returns (ChainConfig memory) {
        // address adminAddress = vm.envAddress("SEPOLIA_ADMIN_ADDRESS");
        // address guardSigner = vm.envAddress("SEPOLIA_GUARDIAN_SIGNER");
        // address guardSetter = vm.envAddress("SEPOLIA_GUARDIAN_SETTER");
        return ChainConfig({ router: address(0), linkAddress: address(1) });
    }
}
