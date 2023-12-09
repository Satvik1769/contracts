// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ProfileNft } from "./ProfileNft.sol";
import {IProfileNft} from "./interfaces/IProfileNft.sol";

contract ProfileFactory {

    error NotMinted();

    address public i_router;
    address public i_linkAddress;

    mapping(address => bool) public profileToIsMinted;

    constructor(address _router, address linkAddress) {
        i_router = _router;
    }

    function createProfile(string calldata _name, string calldata _symbol, string calldata _uri) external {
        ProfileNft _profile = new ProfileNft(_name,_symbol,msg.sender,i_router, _uri, i_linkAddress);
        profileToIsMinted[address(_profile)] = true;
    }

    function makeConnection(address profileAddress, bytes memory sig) external { 
        if (!profileToIsMinted[profileAddress]) {
            revert NotMinted();
        }
        IProfileNft(profileAddress).mintFromFactory(msg.sender,sig);
    }
}
