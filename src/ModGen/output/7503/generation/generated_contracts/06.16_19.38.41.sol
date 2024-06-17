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
    uint public extensionTime;
    uint public numTokensRequired;
    
    mapping(address => uint) public numBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _bidIncrementPercentage, uint _extensionTime, uint _numTokensRequired) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        bidIncrementPercentage = _bidIncrementPercentage;
        extensionTime = _extensionTime;
        numTokensRequired = _numTokensRequired;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= numTokensRequired, "Minimum tokens required to participate");
        require(numBids[msg.sender] < 3, "Maximum 3 bids per address");
        
        uint minBidAmount = highestBid + (highestBid * bidIncrementPercentage / 100);
        require(msg.value >= minBidAmount, "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionTime;
        }
        
        numBids[msg.sender]++;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        address payable organizerPayable = payable(organizer);
        organizerPayable.transfer(highestBid);
    }
}