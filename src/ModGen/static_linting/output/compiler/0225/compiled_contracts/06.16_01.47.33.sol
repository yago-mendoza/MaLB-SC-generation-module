// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant public bidIncrementPercentage = 5;
    uint constant public auctionDuration = 30 minutes;
    uint constant public extensionDuration = 10 minutes;
    uint public totalBids;
    mapping(address => uint) public bidsPerAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
        ticketTokenId = _ticketTokenId;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage) / 100, "Bid increment not met");
        require(bidsPerAddress[msg.sender] < 3, "Maximum 3 bids per address limit reached");

        totalBids++;
        bidsPerAddress[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += extensionDuration;
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}