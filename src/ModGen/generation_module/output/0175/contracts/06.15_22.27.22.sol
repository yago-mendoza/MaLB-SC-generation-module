```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId = 1;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public bidLimit = 3;
    uint constant public auctionDuration = 30 minutes;
    uint constant public bidWithdrawalLockDuration = 10 minutes;
    
    mapping(address => uint) public bidsPerAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= (highestBid * (100 + minBidIncreasePercentage)) / 100, "Bid amount must be at least 5% higher");
        require(bidsPerAddress[msg.sender] < bidLimit, "Exceeded maximum number of bids");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            
            // Reset bid count for new highest bidder
            bidsPerAddress[msg.sender] = 1;
        } else {
            bidsPerAddress[msg.sender]++;
        }
        
        // Extend auction if new bid in last 5 minutes
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}
```