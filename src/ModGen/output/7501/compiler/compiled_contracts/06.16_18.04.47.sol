// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public auctionDuration;
    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidIncrease = 105; // 5% increase
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount >= highestBid * minBidIncrease / 100, "Bid must be at least 5% higher than the current highest bid");
        
        if (block.timestamp >= auctionEndTime - 300) { // Check if within last 5 minutes
            auctionEndTime += 600; // Extend auction by 10 minutes
        }
        
        addressBidCount[msg.sender]++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        
        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}