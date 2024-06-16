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
    uint public numBidsAllowed;
    uint public numTokensRequired;
    uint public constant FIVE_PERCENT = 5;
    
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _numBidsAllowed, uint _numTokensRequired) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = FIVE_PERCENT;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numBidsAllowed = _numBidsAllowed;
        numTokensRequired = _numTokensRequired;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable onlyDuringAuction {
        require(msg.value >= minBidAmount, "Bid amount must be at least the minimum required");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Exceeded maximum number of bids");
        
        uint minIncrement = (highestBid * bidIncrementPercentage) / 100;
        require(msg.value >= highestBid + minIncrement, "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBidsByAddress[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}