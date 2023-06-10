// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IUserRegistry {
    struct User {
        string name;
        string profileCID;
        uint256 level;
        bool registered;
        uint256 appreciationBalance;
        uint256 contributionBalance;
        uint256 appreciationsTaken;
        uint256 appreciationsGiven;
        uint256 takenAmt;
        uint256 givenAmt;
        uint256 tokenId;
        bool tokenHolder;
    }
    function getUserDetails(address user) external view returns (User memory);
    function setTokenId(address _user, uint256 _tokenId) external;
}

interface IVariables {
    function retriveLevelToGovern() external view returns (uint256);
}

contract GovernanceToken is ERC721, Ownable, EIP712, ERC721Votes {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IUserRegistry userRegistry;
    IVariables variables;

    constructor() ERC721("CaringPower", "CP") EIP712("CaringPower", "1") {
        _tokenIdCounter._value = 1;
    }

    modifier onlyActiveParticipator(address to) {
        // @TODO VARIABLE 2
        require(userRegistry.getUserDetails(to).level >= variables.retriveLevelToGovern(), "Reach level 10 to mint");
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://caringcoin.infura-ipfs.io/ipfs/QmWroSNGfL5R7Bf4gH7rQLi4kgMa8HP2QnfanH8tqBtTDW";
    }

    function setUserRegistry(address _userRegistry) external onlyOwner {
        userRegistry = IUserRegistry(_userRegistry);
    }
    
    function setVariables(address _variables) external onlyOwner {
        variables = IVariables(_variables);
    }

    function safeMint(address to) public onlyActiveParticipator(to) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        delegate(to);
        userRegistry.setTokenId(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

    function supply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
}