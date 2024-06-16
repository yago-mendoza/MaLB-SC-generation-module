// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public totalBids;
    uint constant public maxBidsPerAddress = 3;
    uint constant public minBidIncreasePercentage = 5;
    bool public auctionEnded;
    
    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = _bidIncrementPercentage;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    modifier onlyBeforeEnd() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    function placeBid() external payable onlyBeforeEnd {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= highestBid + ((highestBid * minBidIncreasePercentage) / 100), "Bid must be at least 5% higher");
        require(bidsPerAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids");

        totalBids++;
        bidsPerAddress[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewHighestBid(msg.sender, msg.value);

        if (block.timestamp + 5 minutes >= auctionEndTime) {
            auctionEndTime += 10 minutes;
        }
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
    }
}