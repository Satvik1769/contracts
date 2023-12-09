// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/token/ERC721/IERC721.sol";
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { IERC721Receiver } from "@openzeppelin/token/ERC721/IERC721Receiver.sol";
import { Ownable } from "@openzeppelin/access/Ownable.sol";
import {SignatureChecker} from "@openzeppelin/utils/cryptography/SignatureChecker.sol";
import {Client} from "@ccip/ccip/libraries/Client.sol";
import {IRouterClient} from "@ccip/ccip/interfaces/IRouterClient.sol";
// import {} from "@opemzeppelin/c";
import {IProfileNft} from "./interfaces/IProfileNft.sol";
import {IProfileFactory} from "./interfaces/IProfileFactory.sol";

contract ProfileNft is ERC721, Ownable, IERC721Receiver {
    error NotOwnerOrRouter();
    error NotFactory();
    error NotEnoughBalance();
    error NotValidSig();

    string public s_uri;
    uint256 public tokenId;
    address public immutable i_linkAddress;
    address public immutable i_factory;
    IRouterClient public i_routerClient;
    // address

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        bytes data,
        address feeToken,
        uint256 fees
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address owner,
        address router,
        string memory _uri,
        address linkAddress
    ) ERC721(_name, _symbol) Ownable(owner) {
        i_routerClient = IRouterClient(router);
        s_uri = _uri;
        i_linkAddress = linkAddress;
        i_factory = msg.sender;
    }

    modifier onlyOwnerOrRouter() {
        if (msg.sender != owner() || msg.sender != address(i_routerClient)) {
            revert NotOwnerOrRouter();
        }
        _;
    }

    modifier onlyFactory() {
        if (msg.sender != i_factory) {
            revert NotFactory();
        }
        _;
    }

    function mint(
        address toAddress,
        bytes calldata sig,
        uint64 chainSelector
    ) public onlyOwnerOrRouter {
        tokenId++;
        if (chainSelector != 0) {
            // checkSignature();
            _safeMint(toAddress, tokenId);
            bytes32 messageId = sendMessage(chainSelector, toAddress, sig);
        } else {
            _safeMint(toAddress, tokenId);

        }
    }

    function mintFromFactory(
        address toAddress,
        bytes calldata sig
    ) external onlyFactory {
        bool isValidSig = SignatureChecker.isValidSignatureNow(
            owner(),
            hashOfSig(toAddress),
            sig
        );
        if (!isValidSig) {
            revert NotValidSig();
        }
        tokenId++;
        _safeMint(toAddress, tokenId);
    }

    function hashOfSig(address toAddress) public pure returns (bytes32) {
        return keccak256(abi.encode(toAddress));
    }

    function sendMessage(
        uint64 destinationChainSelector,
        address receiver,
        bytes calldata sig
    ) internal returns (bytes32 messageId) {
        bytes memory data = abi.encodeWithSignature(
            "mint(address,bytes,uint64)",
            address(this),
            sig,
            destinationChainSelector
        );
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver address
            data: data, // ABI-encoded string
            tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array indicating no tokens are being sent
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit and non-strict sequencing mode
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            // Set the feeToken  address, indicating LINK will be used for fees
            feeToken: address(i_linkAddress)
        });

        // Get the fee required to send the message
        uint256 fees = i_routerClient.getFee(
            destinationChainSelector,
            evm2AnyMessage
        );

        if (fees > IERC20(i_linkAddress).balanceOf(address(this)))
            revert NotEnoughBalance();

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        IERC20(i_linkAddress).approve(address(i_routerClient), fees);

        // Send the message through the router and store the returned message ID
        messageId = i_routerClient.ccipSend(
            destinationChainSelector,
            evm2AnyMessage
        );
        // Emit an event with message details
        emit MessageSent(
            messageId,
            destinationChainSelector,
            receiver,
            data,
            address(i_linkAddress),
            fees
        );
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
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
    ) external override returns (bytes4) {}
}
