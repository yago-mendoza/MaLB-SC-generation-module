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
    uint public numBidsAllowed;
    uint public numTokensRequired;
    uint public totalTokens;
    
    mapping(address => uint) public numBids;
    mapping(uint => address) public tokenToBidder;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _numBidsAllowed, uint _numTokensRequired) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = 5;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numBidsAllowed = _numBidsAllowed;
        numTokensRequired = _numTokensRequired;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid(uint _tokenID) external payable onlyDuringAuction {
        require(msg.value > 0, "Bid amount must be greater than 0");
        require(msg.value >= (highestBid + (highestBid * bidIncrementPercentage) / 100), "Bid amount must be at least 5% higher than current highest bid");
        require(numBids[msg.sender] < numBidsAllowed, "Exceeded maximum number of bids allowed");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBids[msg.sender]++;
        totalTokens++;
        tokenToBidder[_tokenID] = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}