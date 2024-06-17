// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderBidCount;
    mapping(address => uint[]) public bidderBids;
    mapping(uint => address) public bidToBidder;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionDuration = _auctionDuration;
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
        require(msg.value >= highestBid + (highestBid * minBidIncreasePercentage) / 100, "Bid must be at least 5% higher than current highest bid");
        require(bidderBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBids[msg.sender].push(msg.value);
        bidToBidder[msg.value] = msg.sender;
        bidderBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!auctionEnded, "Auction has already been finalized");

        auctionEnded = true;
        payable(organizer).transfer(highestBid);
    }
}