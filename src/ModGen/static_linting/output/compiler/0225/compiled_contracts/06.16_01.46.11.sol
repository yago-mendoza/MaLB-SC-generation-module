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
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount > highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        // Refund previous highest bidder
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid);
        }
        
        // Update highest bid and bidder
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        
        // Store bid amount for the address
        uint bidCount = addressToBidCount[msg.sender];
        addressToBids[msg.sender][bidCount] = _bidAmount;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
        
        // Automatically extend auction if new bid in last 5 minutes
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime = block.timestamp + 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer winning bid amount to organizer
        payable(organizer).transfer(highestBid);
    }
}