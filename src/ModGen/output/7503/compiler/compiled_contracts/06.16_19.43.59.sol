// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minBidAmount;
    uint public minTokenRequired;
    
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _bidIncrementPercentage, uint _extensionDuration, uint _minBidAmount, uint _minTokenRequired) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minBidAmount = _minBidAmount;
        minTokenRequired = _minTokenRequired;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minBidAmount, "Bid amount must be at least the minimum bid amount");
        require(msg.value % minTokenRequired == 0, "Bid amount must be in multiples of the minimum token required");
        
        uint newBid = msg.value;
        require(newBid >= highestBid + (highestBid * bidIncrementPercentage / 100), "Bid amount must be at least bid increment percentage higher than the current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBidder = msg.sender;
        highestBid = newBid;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, newBid);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}