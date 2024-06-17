// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionExtensionTime;
    uint constant maxBidsPerAddress = 3;
    uint constant minBidIncreasePercentage = 5;
    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionExtensionTime) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionExtensionTime = _auctionExtensionTime;
        auctionEndTime = block.timestamp + 1 hours; // Initial auction duration of 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(bidsPerAddress[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids");
        require(msg.value > highestBid + (highestBid * minBidIncreasePercentage / 100), "Bid amount must be at least 5% higher");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtensionTime;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        bidsPerAddress[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}