// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage = 5;
    uint public numBidsAllowed = 3;
    uint public totalBids;
    bool public auctionEnded;
    
    mapping(address => uint[]) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + (_auctionDurationMinutes * 1 minutes);
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has already ended");
        _;
    }
    
    function placeBid() external payable auctionNotEnded {
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= (highestBid + (highestBid * minBidIncreasePercentage) / 100), "Bid amount must be at least 5% higher than the current highest bid");
        require(bidderBids[msg.sender].length < numBidsAllowed, "Maximum number of bids reached for this address");
        
        totalBids++;
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBids[msg.sender].push(msg.value);
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Transfer funds to the organizer
        payable(organizer).transfer(highestBid);
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
    }
}