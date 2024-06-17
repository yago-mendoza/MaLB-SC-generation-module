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
    bool public auctionEnded;

    mapping(address => uint) public bidderBidCount;
    mapping(address => mapping(uint => uint)) public bidderBids;

    event NewHighestBid(address bidder, uint amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionExtensionTime) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionExtensionTime = _auctionExtensionTime;
        auctionEndTime = block.timestamp + 1 hours; // Initial auction duration of 1 hour
    }

    function placeBid() external payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require((msg.value - highestBid) * 100 >= highestBid * bidIncrementPercentage, "Bid increment percentage not met");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtensionTime;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewHighestBid(msg.sender, msg.value);

        bidderBidCount[msg.sender]++;
        bidderBids[msg.sender][bidderBidCount[msg.sender]] = msg.value;
    }

    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        auctionEnded = true;
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}