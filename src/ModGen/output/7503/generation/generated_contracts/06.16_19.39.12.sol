// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public minTokensRequired;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public constant maxBidsPerAddress = 3;
    uint public numBids;
    
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _bidIncrementPercentage, uint _minTokensRequired, uint _auctionDuration, uint _extensionDuration) {
        organizer = msg.sender;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidIncrease = 100 + _bidIncrementPercentage;
        minTokensRequired = _minTokensRequired;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minTokensRequired, "Minimum tokens required to participate");
        require(numBidsByAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids");
        
        uint minBidAmount = highestBid + (highestBid * minBidIncrease / 100);
        require(msg.value >= minBidAmount, "Bid amount must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        numBidsByAddress[msg.sender]++;
        numBids++;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}