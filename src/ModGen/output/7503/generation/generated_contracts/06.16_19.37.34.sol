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
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(_bidAmount > highestBid * 105 / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = _bidAmount;
        
        emit NewHighestBid(msg.sender, _bidAmount);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes; // Automatically extend auction by 10 minutes if new bid in last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer the winning bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}