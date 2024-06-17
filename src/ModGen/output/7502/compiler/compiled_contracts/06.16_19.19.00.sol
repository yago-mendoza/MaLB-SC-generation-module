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
    uint public minTokenRequired = 10;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionDuration, uint _extensionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minTokenRequired, "Minimum of 10 tokens required to participate");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        uint minBidAmount = highestBid + ((highestBid * bidIncrementPercentage) / 100);
        
        if (msg.value < minBidAmount) {
            revert("Bid amount must be at least 5% higher than the current highest bid");
        }
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        addressBidCount[msg.sender]++;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Perform transfer of highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}