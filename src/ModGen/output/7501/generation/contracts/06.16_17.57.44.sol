// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint256 public auctionEndTime;
    uint256 public highestBid;
    address public highestBidder;
    uint256 public minBidIncreasePercentage;
    uint256 public auctionDuration = 30 minutes;
    bool public auctionEnded;
    
    struct Bid {
        address bidder;
        uint256 amount;
    }
    
    mapping(address => uint256) public numBids;
    mapping(uint256 => Bid) public bids;
    
    event NewHighestBid(address indexed bidder, uint256 amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor(uint256 _minBidIncreasePercentage) {
        organizer = msg.sender;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        
        numBids[msg.sender]++;
        require(numBids[msg.sender] <= 3, "Each address can have a maximum of 3 bids");
        
        if (numBids[msg.sender] == 1 || msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        bids[numBids[msg.sender]] = Bid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        auctionEnded = true;
        auctionEndTime = block.timestamp;
    }
}