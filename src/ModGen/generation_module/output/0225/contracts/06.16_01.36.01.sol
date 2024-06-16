// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage = 105; // 105 represents 5% increase
    uint public constant maxBidsPerAddress = 3;
    uint public bidCount;
    
    mapping(address => uint) public bidsPerAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(msg.value > highestBid && msg.value >= (highestBid * minBidIncreasePercentage) / 100, "Bid amount must be higher than current highest bid and meet minimum increase requirement");
        require(bidsPerAddress[msg.sender] < maxBidsPerAddress, "You have reached the maximum number of bids allowed");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidsPerAddress[msg.sender]++;
        bidCount++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime = block.timestamp + 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}