// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { IRouterClient } from "@ccip/ccip/interfaces/IRouterClient.sol";
// import {} from "@opemzeppelin/c";
// import {} from "filename";

interface IProfileNft is IERC721 {
    error NotOwnerOrRouter();
    error NotFactory();

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        string text,
        address feeToken,
        uint256 fees
    );

    function mint(address toAddress, bytes calldata sig, uint64 chainSelector) external;
    function mintFromFactory(address toAddress, bytes calldata sig) external;
}
