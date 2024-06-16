// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionExtensionTime = 600; // 10 minutes in seconds
    uint public totalBids;
    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionEndTime = block.timestamp + 1 hours; // 1 hour auction duration
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can perform this action");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + bidIncrementPercentage) / 100, "Bid increment percentage not met");
        require(bidsPerAddress[msg.sender] < 3, "Maximum 3 bids per address reached");

        totalBids++;
        bidsPerAddress[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 300) { // Less than 5 minutes remaining
            auctionEndTime += auctionExtensionTime;
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}