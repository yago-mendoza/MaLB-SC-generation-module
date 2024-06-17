// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressBidCount;
    mapping(uint => address) public bidIndex;
    uint public totalBids;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public maxBidsPerAddress = 3;
    uint constant public auctionDuration = 30 minutes;
    uint constant public auctionExtensionDuration = 10 minutes;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(addressBidCount[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtensionDuration;
        }

        addressBidCount[msg.sender]++;
        totalBids++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidIndex[totalBids] = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}