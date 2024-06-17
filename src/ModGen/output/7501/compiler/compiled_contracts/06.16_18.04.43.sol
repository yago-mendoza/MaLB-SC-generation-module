// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsPerAddress;
    uint public totalBids;
    mapping(address => uint) public numBidsByAddress;
    mapping(uint => address) public addressByBidIndex;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsPerAddress, uint _auctionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + _auctionDuration;
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
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(numBidsByAddress[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");
        
        totalBids++;
        numBidsByAddress[msg.sender]++;
        addressByBidIndex[totalBids] = msg.sender;
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime = block.timestamp + 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Perform transfer to organizer
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
        // Perform transfer to organizer
        payable(organizer).transfer(highestBid);
    }
}