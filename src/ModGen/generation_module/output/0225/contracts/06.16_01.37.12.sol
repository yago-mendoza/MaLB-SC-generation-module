// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;
    uint public minBidIncreasePercentage = 5;
    uint public numBidsPerAddress = 3;
    
    mapping(address => uint) public numBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid && msg.value >= (highestBid * (100 + minBidIncreasePercentage) / 100), "Bid amount too low");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids");
        
        if (block.timestamp + extensionDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBids[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Implement fund transfer to the organizer
        payable(organizer).transfer(highestBid);
    }
}