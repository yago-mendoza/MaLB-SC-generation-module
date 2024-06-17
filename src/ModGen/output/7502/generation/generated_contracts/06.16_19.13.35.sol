// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction time to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(bidderBidCount[msg.sender] < 3, "Exceeded maximum bid count");
        require(_bidAmount > highestBid + (highestBid * 5 / 100), "Bid amount must be at least 5% higher than current highest bid");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to the organizer
        payable(organizer).transfer(highestBid);
    }
}