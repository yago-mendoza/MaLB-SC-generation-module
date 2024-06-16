// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public totalTokens;
    
    mapping(address => uint) public bidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _bidIncrementPercentage, uint _extensionDuration, uint _totalTokens) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = _bidIncrementPercentage;
        extensionDuration = _extensionDuration;
        auctionDuration = _auctionDuration;
        totalTokens = _totalTokens;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require((msg.value * 100 / highestBid) >= bidIncrementPercentage, "Bid must be at least 5% higher than current highest bid");
        require(bidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (block.timestamp + extensionDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}