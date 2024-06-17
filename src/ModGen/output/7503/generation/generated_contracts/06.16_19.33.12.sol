// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public minimumBidIncreasePercentage = 5;
    uint public bidIncrement;
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;
    
    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(_bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            if (block.timestamp + extensionDuration > auctionEndTime) {
                auctionEndTime = block.timestamp + extensionDuration;
            } else {
                auctionEndTime += extensionDuration;
            }
        }
        
        if (msg.sender != highestBidder) {
            bidIncrement = (highestBid * minimumBidIncreasePercentage) / 100;
            require(_bidAmount >= highestBid + bidIncrement, "Bid amount must be at least 5% higher than current highest bid");
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
        }
        
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address allowed");
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        addressBidCount[msg.sender]++;
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        
        payable(organizer).transfer(highestBid);
    }
}