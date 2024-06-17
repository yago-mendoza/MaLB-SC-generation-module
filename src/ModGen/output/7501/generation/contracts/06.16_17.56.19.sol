// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public constant maxBidsPerAddress = 3;
    bool public auctionEnded;
    
    mapping(address => uint) public addressToNumBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _auctionDuration, uint _extensionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "You are not the organizer");
        _;
    }
    
    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }
    
    function placeBid() external payable auctionNotEnded {
        require(addressToNumBids[msg.sender] < maxBidsPerAddress, "You have reached the maximum number of bids");
        require(msg.value > highestBid + (highestBid * minBidIncreasePercentage / 100), "Bid amount must be at least 5% higher than the current highest bid");
        
        addressToNumBids[msg.sender]++;
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += extensionDuration;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        
        // Transfer funds to organizer
        // organizer.transfer(highestBid);
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
        
        // Transfer ticket token to highestBidder
        // Transfer funds to organizer
        // organizer.transfer(highestBid);
    }
}