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
    bool public auctionEnded;
    
    mapping(address => uint) public bidderBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDuration, uint _minBidIncrease) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = 5;
        minBidIncrease = _minBidIncrease;
        auctionDuration = _auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * minBidIncrease / 100), "Bid must be at least 5% higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        bidderBidCount[msg.sender]++;
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Perform fund transfer to the organizer
        payable(organizer).transfer(highestBid);
    }
}