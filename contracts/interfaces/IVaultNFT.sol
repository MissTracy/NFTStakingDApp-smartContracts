// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVaultNFT {

    enum Rarity { Common, Rare, Legendary }

    function ownerOf(uint256 tokenId) external view returns (address);

    function vaultNFTs(uint256 tokenId)
        external
        view
        returns (
            uint256,
            Rarity,
            uint256,
            string memory,
            bool
        );

    function transferFrom(address from, address to, uint256 tokenId) external;
}
