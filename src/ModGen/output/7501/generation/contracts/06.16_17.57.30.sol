// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public totalBids;
    mapping(address => uint) public bidderBidCount;
    
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
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= (highestBid * 105 / 100), "Bid must be at least 5% higher than the current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        totalBids++;
        bidderBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Perform transfer of winning bid amount to organizer
        payable(organizer).transfer(highestBid);
    }
}