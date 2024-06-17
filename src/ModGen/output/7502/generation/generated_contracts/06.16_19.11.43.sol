// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minTokensRequired;
    
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionDuration, uint _extensionDuration, uint _minTokensRequired) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minTokensRequired = _minTokensRequired;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minTokensRequired, "Minimum tokens required to participate");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        uint currentBidAmount = bidderBids[msg.sender][bidderBidCount[msg.sender]];
        uint minBidAmount = currentBidAmount + (currentBidAmount * bidIncrementPercentage / 100);
        
        require(msg.value >= minBidAmount, "Bid amount must be at least 5% higher than the current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = msg.value;
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}