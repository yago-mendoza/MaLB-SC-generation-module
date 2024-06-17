// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId = 1;
    
    mapping(address => uint) public addressToBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor(uint _biddingTime) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}