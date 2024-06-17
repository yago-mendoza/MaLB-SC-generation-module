// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage) / 100, "Bid increment percentage not met");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");
        
        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime += extensionDuration;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}