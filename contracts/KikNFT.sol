//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract KikNFT is ERC721{
    uint256 immutable public maxNftSupply;
    uint256 tokenId;

    constructor (uint256 _maxSupply) ERC721("KikNFT", "KIK"){
      maxNftSupply = _maxSupply;
    }

    function mint() public{
        require(tokenId < maxNftSupply, "You can't mint, Already maximum Nft's were minted");
        tokenId++;
        _safeMint(msg.sender, tokenId);
    }
}