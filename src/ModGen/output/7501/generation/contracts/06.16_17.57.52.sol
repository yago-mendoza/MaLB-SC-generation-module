// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidAmount;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public totalBids;
    
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _bidIncrementPercentage, uint _minBidAmount) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
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
        require(msg.value >= minBidAmount, "Bid amount must be at least the minimum bid amount");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage / 100), "Bid amount must be at least bid increment percentage higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Each address can place a maximum of 3 bids");
        
        totalBids++;
        bidderBidCount[msg.sender]++;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            
            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime = block.timestamp + extensionDuration;
            }
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}