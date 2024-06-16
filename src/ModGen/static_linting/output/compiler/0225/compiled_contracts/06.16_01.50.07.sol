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
    uint public extensionDuration;
    uint public numBidsAllowed;
    uint public numBidsPlaced;
    mapping(address => uint) public numBidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _extensionDuration, uint _numBidsAllowed, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numBidsAllowed = _numBidsAllowed;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidIncrease = 105; // 105% of the current highest bid
        auctionEndTime = block.timestamp + _auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid * minBidIncrease / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Maximum number of bids reached for this address");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        numBidsPlaced++;
        numBidsByAddress[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}