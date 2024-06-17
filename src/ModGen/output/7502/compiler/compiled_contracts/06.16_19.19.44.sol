// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public addressToNumBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher");
        require(addressToNumBids[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            
            // Reset number of bids for the address
            addressToNumBids[msg.sender]++;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}