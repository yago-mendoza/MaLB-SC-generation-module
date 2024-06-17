// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public minBidIncreasePercentage;
    uint public bidIncrement;
    uint public numBidsPerAddress;
    uint public totalBids;
    uint constant maxBidsPerAddress = 3;
    uint constant auctionDuration = 30 minutes;
    bool public auctionEnded;
    
    mapping(address => uint) public numBids;
    mapping(uint => address) public bidIndex;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _minBidIncreasePercentage, uint _bidIncrement, uint _numBidsPerAddress) {
        organizer = msg.sender;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        bidIncrement = _bidIncrement;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }
    
    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid + bidIncrement, "Bid must be at least 5% higher than current highest bid");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");
        
        totalBids++;
        numBids[msg.sender]++;
        bidIndex[totalBids] = msg.sender;
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (block.timestamp + 5 minutes >= auctionEndTime) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        
        // Transfer funds to organizer
        // organizer.transfer(highestBid);
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
        
        // Transfer funds to organizer
        // organizer.transfer(highestBid);
    }
}