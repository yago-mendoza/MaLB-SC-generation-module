// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    
    mapping(address => uint) public addressToBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier onlyBeforeAuctionEnd() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable onlyBeforeAuctionEnd {
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if new bid is within last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        (bool success, ) = organizer.call{value: highestBid}("");
        require(success, "Transfer failed");
    }
}