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
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid && msg.value > 0, "Bid must be higher than current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}