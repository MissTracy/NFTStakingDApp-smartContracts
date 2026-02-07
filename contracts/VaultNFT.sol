// This contract only:
// Stores NFTs
// Sells NFTs
// Tracks rarity
// Tracks user purchases (NEW)


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultNFT is ERC721URIStorage, Ownable {

    enum Rarity { Common, Rare, Legendary }

    struct NFT {
        uint256 tokenId;
        Rarity rarity;
        uint256 price;   // in wei
        string uri;      // metadata/image
        bool sold;
    }

    uint256 private _nextTokenId;

    // tokenId => NFT data
    mapping(uint256 => NFT) public vaultNFTs;

    // NEW: user => owned tokenIds (FOR UI)
    mapping(address => uint256[]) private _userNFTs;

    event NFTAdded(uint256 tokenId, Rarity rarity, uint256 price, string uri);
    event NFTPurchased(uint256 tokenId, address buyer);

    constructor() ERC721("VaultNFT", "VNFT") Ownable(msg.sender) {}

    
    function addNFT(
        Rarity rarity,
        uint256 price,
        string memory uri
    ) external onlyOwner {
        uint256 tokenId = _nextTokenId++;

        vaultNFTs[tokenId] = NFT({
            tokenId: tokenId,
            rarity: rarity,
            price: price,
            uri: uri,
            sold: false
        });

        emit NFTAdded(tokenId, rarity, price, uri);
    }


    function getAvailableNFTs() external view returns (NFT[] memory) {
        uint256 count = 0;

        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (!vaultNFTs[i].sold) {
                count++;
            }
        }

        NFT[] memory available = new NFT[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (!vaultNFTs[i].sold) {
                available[index] = vaultNFTs[i];
                index++;
            }
        }

        return available;
    }

    // BUY NFT (FREE)
    
    function buyNFT(uint256 tokenId) external payable {
        NFT storage nft = vaultNFTs[tokenId];

        require(!nft.sold, "NFT already sold");
        require(msg.value >= nft.price, "Insufficient ETH");

        nft.sold = true;

        // Mint NFT
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, nft.uri);

        // NEW: Track ownership for UI
        _userNFTs[msg.sender].push(tokenId);

        // Refund excess ETH
        if (msg.value > nft.price) {
            payable(msg.sender).transfer(msg.value - nft.price);
        }

        emit NFTPurchased(tokenId, msg.sender);
    }

  
    function getUserNFTs(address user)
        external
        view
        returns (uint256[] memory)
    {
        return _userNFTs[user];
    }

  
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
