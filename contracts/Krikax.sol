// SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./WhiteList.sol";

contract Krikax is ERC721Enumerable, Ownable{
    uint256 constant public TOTAL_SUPPLY = 20000;
    uint256 constant public PRICE_OF_NFT= 0.1 ether;

    uint256 public reservedTokens;
    uint256 public claimendTokens;

    WhiteList whitelist;

constructor (address whitelistContract) ERC721("Krikax", "KIK") {
        whitelist = WhiteList(whitelistContract);
        reservedTokens = whitelist.maxWhiteListAccounts();
    }

function mint() public payable{
    require( claimendTokens < TOTAL_SUPPLY , "MAX SUPPLY REACHED , NO TOKEN WILL BE MINTED AGAIN");
    require( balanceOf(msg.sender) <  PRICE_OF_NFT, "NOT ENOUGHT ETHER TO MINT");
    require(!whitelist.whiteListedAddressess(msg.sender), "ALREADY OWNED");
    claimendTokens++;
    _safeMint(msg.sender, claimendTokens);
 
}

function withdraw() public onlyOwner {
address _owner = owner();
 (bool sent , ) = _owner.call{value: address(this).balance}("");
require(sent, "WITHDRAW FAILED");
}

}