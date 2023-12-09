// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ProfileNft } from "./ProfileNft.sol";
import { IProfileNft } from "./interfaces/IProfileNft.sol";

contract ProfileFactory {
    error NotMinted();

    event ProfileMinted(address indexed profileAddress, address indexed owner, string indexed uri);

    // address public i_router;
    address public i_linkAddress;

    mapping(address => bool) public profileToIsMinted;

    constructor() { }

    function createProfile(string calldata _name, string calldata _symbol, string calldata _uri) external returns (address profileAddress) {
        ProfileNft _profile = new ProfileNft(_name,_symbol,msg.sender,_uri);
        profileToIsMinted[address(_profile)] = true;
        profileAddress = address(_profile);
        emit ProfileMinted(profileAddress, msg.sender, _uri);
    }

    function makeConnection(address profileAddress, bytes memory sig) external {
        if (!profileToIsMinted[profileAddress]) {
            revert NotMinted();
        }
        IProfileNft(profileAddress).mintFromFactory(msg.sender, sig);
    }
}
