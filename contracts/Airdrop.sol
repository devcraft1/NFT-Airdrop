// //SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Airdrop is ERC721 {
    address public admin;
    mapping(address => bool) public processedAirdrops;
    uint256 public claimedNft;

    event AirdropProcessed(address receiver, uint256 toknId, uint256 date);

    constructor(
        string memory name,
        string memory symbol,
        address _admin
    ) ERC721(name, symbol) {
        admin = _admin;
    }

    function updateAdmin(address newAdmin) external {
        require(msg.sender == admin, "only admin");
        admin = newAdmin;
    }

    function claim(
        address receiver,
        uint256 tokenId,
        bytes calldata signature
    ) external {
        bytes32 message = prefixed(
            keccak256(abi.encodePacked(receiver, tokenId))
        );
        require(recoverSigner(message, signature) == admin, "wrong signature");
        require(
            processedAirdrops[receiver] == false,
            "airdrop already processed"
        );
        processedAirdrops[receiver] = true;
        _safeMint(receiver, tokenId);
        emit AirdropProcessed(receiver, tokenId, block.timestamp);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}
