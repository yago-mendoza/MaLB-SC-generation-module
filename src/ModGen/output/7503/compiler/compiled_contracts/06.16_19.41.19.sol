// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public auctionDuration;
    uint public extensionDuration;
    
    mapping(address => uint) public addressToBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _bidIncrement, uint _auctionDuration, uint _extensionDuration) {
        organizer = msg.sender;
        bidIncrement = _bidIncrement;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid + bidIncrement, "Bid increment not met");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}