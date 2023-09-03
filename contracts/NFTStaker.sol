//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract NFTStaker is ERC20, ReentrancyGuard {
IERC721 nftContract;

uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
uint256 constant BASE_YIELD_RATE = 1000 ether;

struct Staker{
    uint256 currentYield; // N number of Tokens every 24 hours
    uint256 lastCheckedPoint; // when was the last time rewars calculated
    uint256 rewards; // when was the tokens accumulated , but not claimed , so far
    uint256[] stakedNfts; // staker staked NFTs
}

mapping(address => Staker) public stakers;
mapping (uint256 => address) public stakedTokenOwner;

constructor (address _nftcontract , string memory name, string memory symbol) ERC20(name, symbol){
    nftContract = IERC721(_nftcontract);
}

function stake(uint256[] memory tokenIds) public{
    Staker storage user = stakers[msg.sender];
    uint256 yield = user.currentYield;
    uint256 noOfTokenIds = tokenIds.length;

   for(uint256 i =0; i< noOfTokenIds;i++ ){
    require(nftContract.ownerOf(tokenIds[i]) == msg.sender,'Not the Owner');
    require(stakedTokenOwner[tokenIds[i]] == msg.sender, "This token was already Staked");
    nftContract.safeTransferFrom(msg.sender , address(this), tokenIds[i]);
    stakedTokenOwner[tokenIds[i]] = msg.sender;
    yield+=BASE_YIELD_RATE;
    user.stakedNfts.push(tokenIds[i]);
   }    

   accumulate(msg.sender);
   user.currentYield =yield;
}

function accumulate(address staker) internal {
stakers[staker].rewards  += getRewards(staker);
stakers[staker].lastCheckedPoint = block.timestamp; 
}

function getRewards(address staker) public view returns(uint256){
Staker memory user = stakers[staker];
if(user.lastCheckedPoint == 0){
    return 0;
}
return ((block.timestamp - user.lastCheckedPoint) * user.currentYield) / SECONDS_PER_DAY;
}

function unstake(uint256[] memory tokenIds) public{
    Staker storage user = stakers[msg.sender];
    uint256 yield = user.currentYield;

    uint256 tokenIdsLength = tokenIds.length;
    for(uint256 i=0;i< tokenIdsLength; i++){
     require(stakedTokenOwner[tokenIds[i]] == msg.sender, "Not Real Owner");
     require(nftContract.ownerOf(tokenIds[i]) == address(this),'Not the Contract Owner');
     if(yield !=0)
       yield-=BASE_YIELD_RATE;

    nftContract.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
    }
    accumulate(msg.sender);
    user.currentYield= yield;
}

function claim() public nonReentrant{
    Staker storage user = stakers[msg.sender];
    accumulate(msg.sender);
    _mint(msg.sender, user.rewards);
    user.rewards=0;
}
}