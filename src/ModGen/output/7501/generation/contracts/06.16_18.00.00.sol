// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public minBidAmount;
    uint public auctionDuration = 30 minutes;
    uint public lastBidTime;
    uint public extensionTime = 10 minutes;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _minBidAmount) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidAmount = _minBidAmount;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minBidAmount, "Bid amount too low");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage / 100), "Bid amount must be at least bid increment percentage higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if(block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionTime;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        lastBidTime = block.timestamp;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        (bool success, ) = organizer.call{value: highestBid}("");
        require(success, "Transfer failed");
    }
}