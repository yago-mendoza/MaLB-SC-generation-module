// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public minBidIncreasePercentage;
    uint public auctionDuration = 30 minutes;
    uint public lastBidTime;
    uint public extensionTime = 10 minutes;
    uint public numTokensRequired = 10;
    
    mapping(address => uint) public numBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _bidIncrement, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        bidIncrement = _bidIncrement;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= numTokensRequired * 1 ether, "Minimum of 10 tokens required to participate");
        require(numBids[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        uint newBidAmount = msg.value;
        require(newBidAmount >= highestBid + bidIncrement, "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionTime;
        }
        
        highestBid = newBidAmount;
        highestBidder = msg.sender;
        lastBidTime = block.timestamp;
        numBids[msg.sender]++;
        
        emit NewHighestBid(msg.sender, newBidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        (bool success, ) = organizer.call{value: highestBid}("");
        require(success, "Transfer failed");
    }
}