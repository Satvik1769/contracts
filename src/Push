// SPDX-License-Identifier: MIT

// sepolia contract address: 0x0C34d54a09CFe75BCcd878A469206Ae77E0fe6e7

import "./IPUSHCommInterface.sol";
pragma solidity ^0.8.0;

contract Push {
    address public constant EPNS_COMM_CONTRACT_ADDRESS_FOR_SPECIFIC_BLOCKCHAIN =
        0x0C34d54a09CFe75BCcd878A469206Ae77E0fe6e7;

    IPUSHCommInterface public pushComm =
        IPUSHCommInterface(EPNS_COMM_CONTRACT_ADDRESS_FOR_SPECIFIC_BLOCKCHAIN);

    function sendNotification(address from, address to) external {
        pushComm.sendNotification(
            from,
            to,
            bytes(
                string(
                    abi.encodePacked(
                        "0",
                        "+",
                        "3",
                        "+",
                        "Sent",
                        "+",
                        "Message sent to the device."
                    )
                )
            )
        );
    }
}
