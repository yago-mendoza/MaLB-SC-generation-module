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
    uint public totalTickets;
    uint public totalBids;

    mapping(address => uint) public bidderBidCount;
    mapping(address => uint[]) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _extensionDuration, uint _totalTickets, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        highestBid = 0;
        highestBidder = address(0);
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        totalTickets = _totalTickets;
        totalBids = 0;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    modifier auctionOpen() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    function placeBid() external payable auctionOpen {
        require(totalBids < totalTickets * 3, "All tickets have been auctioned");
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require((msg.value * 100 / highestBid) >= bidIncrementPercentage, "Bid increment percentage not met");
        
        totalBids++;
        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender].push(msg.value);

        if (bidderBidCount[msg.sender] > 3) {
            revert("Maximum 3 bids per address allowed");
        }

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            auctionEndTime = block.timestamp + auctionDuration;
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}