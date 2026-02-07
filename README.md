# 🌐 NFTStakingDApp-smartContracts🌐 
Smart contracts for an NFT staking dApp deployed on Sepolia

This repository contains the **core smart contracts** developed for an **Ethereum NFT staking dApp**, deployed on the **Sepolia testnet**.

The full decentralized application allows users to purchase NFTs, stake them for fixed durations, and earn ERC20 reward tokens based on NFT rarity and lock period.  
This repo focuses specifically on showcasing the **on-chain logic and contract architecture**.

---

##  Project Overview

RedStakeETH is an NFT staking protocol with the following flow:

1. NFTs are created and sold through a Vault contract
2. Purchased NFTs are minted directly into the user’s **MetaMask wallet**
3. Users can stake their NFTs for **30, 60, or 90 days**
4. Rewards are calculated based on:
   - NFT rarity (Common / Rare / Legendary)
   - Lock duration
5. ERC20 reward tokens are **minted on withdrawal**
6. The total reward supply is capped at **1,000,000 tokens**, enforced on-chain

---

##  Smart Contract Architecture

###  VaultNFT.sol
- ERC721 contract
- Mints NFTs with predefined rarity and price
- Tracks NFT metadata and ownership
- Ensures purchased NFTs are real, unique, and securely owned by users

###  NFTStaking.sol
- Handles NFT staking and withdrawals
- NFTs are escrowed securely during the staking period
- Supports 30 / 60 / 90 day lock durations
- Calculates rewards based on rarity and duration
- Protected against reentrancy attacks

###  RewardToken.sol
- ERC20 reward token (18 decimals)
- Tokens are minted **dynamically as rewards**
- Hard supply cap of **1,000,000 tokens**
- Minting restricted to the staking contract only

###  IVaultNFT.sol
- Interface used by the staking contract
- Ensures safe interaction with the NFT vault

---

##  Security Considerations

- Reentrancy protection on stake and withdraw
- Reward minting restricted via `onlyOwner`
- Total ERC20 supply capped at contract level
- NFTs are transferred and escrowed securely
- No private keys or secrets stored on-chain

---

## Tech Stack

- **Solidity ^0.8.20**
- **Hardhat**
- **OpenZeppelin Contracts**
- **Ethers.js**
- **Vanilla JavaScript, HTML, CSS (Frontend)**
- **MetaMask Wallet Integration**
- **Sepolia Testnet Deployment**

---

##  Deployment

- Network: **Sepolia Testnet**
- Contracts are deployed and verified
- Frontend interacts with deployed contracts via Ethers.js

---

##  Notes

This repository is intended to showcase **smart contract design and security patterns**.  
Frontend code and environment configuration files are excluded to protect private keys and API credentials.

---

## 👩‍💻 Author

Developed by **Miss Tracy**  
Web3 / Blockchain Developer

