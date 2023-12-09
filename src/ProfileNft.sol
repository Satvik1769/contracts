// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { IERC721Receiver } from "@openzeppelin/token/ERC721/IERC721Receiver.sol";
import { Ownable } from "@openzeppelin/access/Ownable.sol";
import { SignatureChecker } from "@openzeppelin/utils/cryptography/SignatureChecker.sol";
import { IProfileNft } from "./interfaces/IProfileNft.sol";
import { IProfileFactory } from "./interfaces/IProfileFactory.sol";

contract ProfileNft is ERC721, Ownable, IERC721Receiver {
    error NotOwnerOrRouter();
    error NotFactory();
    error NotEnoughBalance();
    error NotValidSig();

    struct Moment {
        address userA;
        address userB;
        uint64 createdAt;
        uint256 eventId;
    }

    event MomentMinted(address indexed profile2, uint256 indexed eventId);

    string public s_uri;
    uint256 public tokenId;

    IProfileFactory public immutable i_factory;
    mapping(uint256 tokenId => Moment moment) tokenIdToMoment;

    constructor(
        string memory _name,
        string memory _symbol,
        address owner,
        string memory _uri
    )
        ERC721(_name, _symbol)
        Ownable(owner)
    {
        s_uri = _uri;
        i_factory = IProfileFactory(msg.sender);
    }

    modifier onlyFactory() {
        if (msg.sender != address(i_factory)) {
            revert NotFactory();
        }
        _;
    }

    function mint(address toAddress, bytes calldata sig, uint64 eventId) public onlyOwner {
        tokenId++;
        _safeMint(toAddress, tokenId);
        tokenIdToMoment[tokenId] =
            Moment({ userA: address(this), userB: toAddress, createdAt: uint64(block.timestamp), eventId: eventId });
        i_factory.makeConnection(toAddress, sig, eventId);
        emit MomentMinted(toAddress, eventId);
    }

    function mintFromFactory(address toAddress, bytes calldata sig, uint256 eventId) external onlyFactory {
        bool isValidSig = SignatureChecker.isValidSignatureNow(owner(), hashOfSig(toAddress), sig);
        if (!isValidSig) {
            revert NotValidSig();
        }
        tokenIdToMoment[tokenId] =
            Moment({ userA: address(this), userB: toAddress, createdAt: uint64(block.timestamp), eventId: eventId });
        tokenId++;
        _safeMint(toAddress, tokenId);
        emit MomentMinted(toAddress, eventId);
    }

    function hashOfSig(address toAddress) public pure returns (bytes32) {
        return keccak256(abi.encode(toAddress));
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory baseURI = _baseURI();
        return baseURI;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view override returns (string memory) {
        return s_uri;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )
        external
        override
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
}
