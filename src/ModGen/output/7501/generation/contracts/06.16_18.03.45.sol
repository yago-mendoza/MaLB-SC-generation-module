// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public auctionDuration;
    uint public extensionDuration;
    
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _minBidIncrease) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minBidIncrease = _minBidIncrease;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid + minBidIncrease, "Bid amount must be at least 5% higher than the current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}