```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration = 60 minutes;
    uint public extensionDuration = 10 minutes;
    uint public constant maxBidsPerAddress = 3;
    uint public constant minBidIncreasePercentage = 5;
    bool public auctionEnded;
    
    mapping(address => uint) public bidsPerAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor(uint _bidIncrementPercentage) {
        organizer = msg.sender;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(bidsPerAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidsPerAddress[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
    }
}
```