// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsAllowed;
    uint public numBidsPlaced;
    bool public auctionEnded;
    mapping(address => uint[]) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsAllowed, uint _durationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsAllowed = _numBidsAllowed;
        auctionEndTime = block.timestamp + (_durationMinutes * 1 minutes);
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable onlyDuringAuction {
        require(msg.value > highestBid && msg.value >= (highestBid + (highestBid * minBidIncreasePercentage) / 100), "Bid amount must be higher than current highest bid by at least the minimum percentage increase");
        require(bidderBids[msg.sender].length < numBidsAllowed, "Maximum number of bids reached for this address");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        bidderBids[msg.sender].push(msg.value);
        numBidsPlaced++;
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        auctionEnded = true;
    }
}