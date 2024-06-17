// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public numTickets;
    uint public numBidsAllowed;
    
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _numTickets, uint _numBidsAllowed, uint _bidIncrement, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numTickets = _numTickets;
        numBidsAllowed = _numBidsAllowed;
        bidIncrement = _bidIncrement;
        minBidIncreasePercentage = _minBidIncreasePercentage;
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
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require((msg.value - highestBid) * 100 / highestBid >= minBidIncreasePercentage, "Bid must be at least 5% higher than the current highest bid");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Maximum number of bids reached for this address");
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        numBidsByAddress[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime = block.timestamp + extensionDuration;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}