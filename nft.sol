// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4; 


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";         // Import Counters 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

contract EthereumBadgesNFT is ERC721, Ownable {
    using Counters for Counters.Counter;                     // Let's contract know that we're going to use it
    // Important changes -> emit events
    event NewSupply(uint256 _newSupply);                     
    event Withdrawal(uint256 amount);
    event NewURI (string _newURI);
    event FrozenURI();                        

    Counters.Counter internal nextId;                        // This is used to declare a counter which is used to store the next tokenId

    uint256 public maxSupply = 101;                          // Max supply is 101 

    string public baseURI;                                   // Set Base URI String
    bool public frozen;                                      // Check if the URI is frozen
    constructor() ERC721("Ethereum Badges", "ETHBADGES") {}

    function mint() external payable {                               // Function to mint NFT
        require(msg.value == 0.05 ether,"VALUE");
        uint256 tokenId = nextId.current();                  // Used to get current counter 
        require(tokenId < maxSupply, "EXCEEDS MAX SUPPLY!"); // Used to enforce the max supply 
        nextId.increment();                                  // Increment counter by 1 
        _mint(msg.sender, tokenId);                          // Call low-level mint
    }

    function reduceSupply(uint256 _newSupply) external {    // Function to reduce supply after one is minted
                                                             // This is used to enforce limits
        require(_newSupply < maxSupply && _newSupply >= nextId.current(), "INVALID INPUT");
        maxSupply = _newSupply;                             // _newSupply is the new max supply  
        emit NewSupply(_newSupply);                         // Emit Event 
    }

    function totalSupply() external view returns (uint256) { // Function to retrieve total # of tokens minted
        return nextId.current() - 1;                         // Return the total of tokens minted 
       // uint256 supplyRemaining = maxSupply - 
    }

	function withdraw() external onlyOwner {                 // Function to allow for ether to be withdraw from contract
		uint256 amount = address(this).balance;              // This is used to get contracts ether balance
		payable(msg.sender).transfer(amount);                // This will send ether to the caller
		emit Withdrawal(amount);                             // Emit Event 
	}

	function setURI(string memory _newURI) external onlyOwner {
		require(!frozen,"URI is frozen");
		baseURI = _newURI;
        emit NewURI(_newURI);
	}

	function freezeURI() external onlyOwner {
		require(!frozen,"URI is already frozen");
		frozen = true;
        emit FrozenURI();
	}


}


