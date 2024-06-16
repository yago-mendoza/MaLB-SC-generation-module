// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public auctionDuration = 30 minutes;
    uint constant public auctionExtensionDuration = 10 minutes;
    uint public numBidsPerAddress = 3;
    
    mapping(address => uint) public numBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
        ticketTokenId = _ticketTokenId;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= (highestBid * (100 + minBidIncreasePercentage)) / 100, "Bid amount must be at least 5% higher");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids");
        
        if (block.timestamp + auctionExtensionDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + auctionExtensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBids[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}