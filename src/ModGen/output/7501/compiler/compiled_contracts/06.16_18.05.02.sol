// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public addressToBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _auctionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime = block.timestamp + 10 minutes;
        }
        
        addressToBidCount[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Withdraw the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}