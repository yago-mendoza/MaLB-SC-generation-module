// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    
    mapping(address => uint) public addressToNumBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _ticketTokenId, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require((msg.value * 100 / highestBid) >= minBidIncreasePercentage, "Bid must be at least 5% higher than current highest bid");
        require(addressToNumBids[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        addressToNumBids[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Perform transfer to organizer
        payable(organizer).transfer(highestBid);
    }
}