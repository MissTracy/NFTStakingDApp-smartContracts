// erc20 Tokens have 18 decimals by default SO 1 token = 1 * 10^18 units on-chain
// Reward tokens are minted dynamically as users earn rewards, but the contract 
// enforces a hard cap of 1 million tokens. Once the cap is reached, no further r
// ewards can be minted.
// so this contract enforces the 1M cap

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; // 1 million tokens

constructor() ERC20("RewardToken", "RWT") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        //Require because rewards cannot exceed 1,000,000 tokens in total.
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply reached");
        _mint(to, amount);
    }
}
