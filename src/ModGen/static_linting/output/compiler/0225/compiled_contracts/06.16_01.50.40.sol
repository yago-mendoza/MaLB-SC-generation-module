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
    uint public totalTokensRequired;
    uint public totalBidsAllowedPerAddress;
    
    mapping(address => uint) public addressToBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _bidIncrementPercentage, uint _minBidAmount, uint _auctionDuration, uint _totalTokensRequired, uint _totalBidsAllowedPerAddress) {
        organizer = msg.sender;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidAmount = _minBidAmount;
        auctionDuration = _auctionDuration;
        totalTokensRequired = _totalTokensRequired;
        totalBidsAllowedPerAddress = _totalBidsAllowedPerAddress;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(msg.value >= minBidAmount, "Bid amount must be at least the minimum bid amount");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(addressToBidCount[msg.sender] < totalBidsAllowedPerAddress, "Maximum bids per address reached");
        
        uint currentHighestBid = highestBid;
        uint minBidIncrement = (currentHighestBid * bidIncrementPercentage) / 100;
        uint newBidAmount = currentHighestBid + minBidIncrement;
        
        require(msg.value >= newBidAmount, "Bid amount must be at least 5% higher than the current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}