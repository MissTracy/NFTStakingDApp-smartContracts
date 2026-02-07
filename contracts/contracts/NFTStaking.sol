    // lets users stake NFTs from VaultNFT and mints RewardToken based on rarity.
    // When a user withdraws their staked NFT, the staking contract calculates the 
    // reward based on rarity and lock duration, then mints reward tokens directly 
    // to the user. The total reward supply is capped at one million tokens



    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.20;

    import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
    import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";
    // import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
    import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
    import "./interfaces/IVaultNFT.sol";
    import "./RewardToken.sol";



    contract NFTStaking is Ownable, ReentrancyGuard, IERC721Receiver {
        IVaultNFT public vaultNFT;
        RewardToken public rewardToken; // Type RewardToken allows mint()

        struct Stake {
            uint256 tokenId;
            uint256 startTime;
            uint256 duration; // in seconds
            uint8 rarity;     // 0=Common,1=Rare,2=Legendary
            bool withdrawn;
        }

        mapping(address => Stake[]) public stakes;

        // Staking durations
        uint256 public constant DURATION_30 = 30 days;
        uint256 public constant DURATION_60 = 60 days;
        uint256 public constant DURATION_90 = 90 days;

        // Base reward per NFT rarity (for 30-day staking)
        uint256 public constant REWARD_COMMON = 50 * 1e18;      // 50 RWT
        uint256 public constant REWARD_RARE = 100 * 1e18;       // 100 RWT
        uint256 public constant REWARD_LEGENDARY = 200 * 1e18;  // 200 RWT

        // ---------------- CONSTRUCTOR ----------------
        constructor(address _vaultNFT, address _rewardToken) Ownable(msg.sender) {
            vaultNFT = IVaultNFT(_vaultNFT);
            rewardToken = RewardToken(_rewardToken);
        }

        // ---------------- EVENTS ----------------
        event Staked(address indexed user, uint256 tokenId, uint256 duration, uint8 rarity);
        event Withdrawn(address indexed user, uint256 tokenId, uint256 reward);

        // ---------------- STAKE ----------------
        function stake(uint256 tokenId, uint256 duration) external nonReentrant {
            require(
                duration == DURATION_30 || duration == DURATION_60 || duration == DURATION_90,
                "Invalid duration"
            );
            require(vaultNFT.ownerOf(tokenId) == msg.sender, "Not your NFT");

            uint8 rarity = _getNFT_Rarity(tokenId);

            // Transfer NFT into staking contract
            vaultNFT.transferFrom(msg.sender, address(this), tokenId);

            stakes[msg.sender].push(Stake(tokenId, block.timestamp, duration, rarity, false));
            emit Staked(msg.sender, tokenId, duration, rarity);
        }

        // ---------------- WITHDRAW ----------------
        function withdraw(uint256 stakeIndex) external nonReentrant {
            Stake storage s = stakes[msg.sender][stakeIndex];
            require(!s.withdrawn, "Already withdrawn");
            require(block.timestamp >= s.startTime + s.duration, "Stake locked");

            s.withdrawn = true;

            // Calculate reward
            uint256 reward = _calculateReward(s.rarity, s.duration);

            // Mint reward tokens to user
            rewardToken.mint(msg.sender, reward);

            // Return NFT to user
            vaultNFT.transferFrom(address(this), msg.sender, s.tokenId);

            emit Withdrawn(msg.sender, s.tokenId, reward);
        }

        // ---------------- VIEW FUNCTIONS ----------------
        function getStakeCount(address user) external view returns (uint256) {
            return stakes[user].length;
        }

        function stakesOf(address user, uint256 index) external view returns (Stake memory) {
            return stakes[user][index];
        }

        // ---------------- INTERNAL ----------------
        function _calculateReward(uint8 rarity, uint256 duration) internal pure returns (uint256) {
            if (rarity == 0) return REWARD_COMMON * duration / DURATION_30;
            if (rarity == 1) return REWARD_RARE * duration / DURATION_30;
            return REWARD_LEGENDARY * duration / DURATION_30;
        }

        function _getNFT_Rarity(uint256 tokenId) internal view returns (uint8) {
            (, IVaultNFT.Rarity rarity,,,) = vaultNFT.vaultNFTs(tokenId);
            return uint8(rarity);
        }

        function onERC721Received(
            address,
            address,
            uint256,
            bytes calldata
        ) external pure override returns (bytes4) {
            return IERC721Receiver.onERC721Received.selector;
        }

    }
