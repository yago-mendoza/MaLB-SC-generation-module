// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    mapping(address => mapping(uint => uint)) public addressToBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
    }
    
    function placeBid(uint bidAmount) external payable onlyDuringAuction {
        require(bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require(bidAmount >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        if (block.timestamp + 5 minutes >= auctionEndTime) {
            auctionEndTime += 10 minutes;
        }
        
        highestBidder = msg.sender;
        highestBid = bidAmount;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = bidAmount;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, bidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}