// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minBidIncrease;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _minBidIncrease) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = _minBidIncrease;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minBidIncrease = _minBidIncrease;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid + ((highestBid * bidIncrementPercentage) / 100), "Bid must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        addressBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}