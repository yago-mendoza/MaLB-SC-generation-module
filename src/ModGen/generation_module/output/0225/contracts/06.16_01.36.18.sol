// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    
    struct Bid {
        address bidder;
        uint amount;
    }
    
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    Bid public highestBidder;
    
    mapping(address => uint) public numBids;
    mapping(address => Bid[3]) public bidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    function placeBid(uint _tokenID) external payable onlyDuringAuction {
        require(msg.value > 0, "Bid amount must be greater than 0");
        require(numBids[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        uint minBidAmount = highestBid + (highestBid * 5 / 100);
        require(msg.value >= minBidAmount, "Bid amount must be at least 5% higher than current highest bid");
        
        Bid memory newBid = Bid(msg.sender, msg.value);
        bidsByAddress[msg.sender][numBids[msg.sender]] = newBid;
        numBids[msg.sender]++;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = newBid;
            emit NewHighestBid(newBid.bidder, newBid.amount);
            
            if (auctionEndTime - block.timestamp < 5 minutes) {
                auctionEndTime += 10 minutes;
            }
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}