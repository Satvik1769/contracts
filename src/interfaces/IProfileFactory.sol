// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IProfileFactory {
    function createProfile(string calldata _name, string calldata _symbol, string calldata _uri) external;
    function makeConnection(address profileAddress, bytes memory sig) external;
}
