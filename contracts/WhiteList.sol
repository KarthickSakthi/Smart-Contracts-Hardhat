// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18 ;

contract WhiteList{

uint256 public maxWhiteListAccounts =0;
uint256 public currentWhiteListedAddressesCount =0;
mapping(address => bool) public whiteListedAddressess;
address payable owner;

    constructor(uint _maxWhiteListAcoountsCount){
        maxWhiteListAccounts = _maxWhiteListAcoountsCount;
        owner = payable(msg.sender);
    }

modifier onlyOwner(){
    require(owner == msg.sender, "You're don't have access to permit this action");
    _;
}

function addressTobeWhiteListed() public{
    require(!whiteListedAddressess[msg.sender], "Your account was already whitelisted, you can't whitelist again");
    require(currentWhiteListedAddressesCount < maxWhiteListAccounts, "Your account was'nt able to whiteList, whiteList Account limit was already reached");
    whiteListedAddressess[msg.sender] = true;
    currentWhiteListedAddressesCount++;
}

function updateMaximumWhiteListAccounts(uint256 _updatedCount) onlyOwner internal {
    require(_updatedCount > maxWhiteListAccounts, "You can't reduce the maximum count that already exist");
    maxWhiteListAccounts = _updatedCount;
}


}