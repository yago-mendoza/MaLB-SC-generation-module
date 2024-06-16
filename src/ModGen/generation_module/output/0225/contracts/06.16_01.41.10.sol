// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public bidLimitPerAddress;
    uint public totalBids;
    uint constant extensionTime = 600; // 10 minutes in seconds

    mapping(address => uint) public addressToBidCount;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _bidLimitPerAddress, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        bidLimitPerAddress = _bidLimitPerAddress;
        auctionEndTime = block.timestamp + (_auctionDurationMinutes * 1 minutes);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can perform this action");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid && msg.value >= (highestBid + (highestBid * minBidIncreasePercentage) / 100), "Bid amount too low");

        if (block.timestamp > auctionEndTime - 300 && block.timestamp < auctionEndTime) {
            auctionEndTime += extensionTime;
        }

        totalBids++;
        addressToBidCount[msg.sender]++;

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}