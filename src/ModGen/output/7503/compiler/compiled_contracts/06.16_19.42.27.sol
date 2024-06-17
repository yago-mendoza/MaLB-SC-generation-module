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
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(_bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require(_bidAmount >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = _bidAmount;
        
        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
            
            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime += 10 minutes; // Extend auction by 10 minutes if new highest bid in last 5 minutes
            }
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        address payable organizerPayable = payable(organizer);
        organizerPayable.transfer(highestBid);
    }
}