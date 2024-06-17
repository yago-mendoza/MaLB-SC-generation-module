// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public minBidIncreasePercentage;
    uint public bidLimit;
    uint public numBids;
    mapping(address => uint) public addressToNumBids;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _minBidIncreasePercentage, uint _bidLimit) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        bidLimit = _bidLimit;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require((msg.value * 100 / highestBid) >= minBidIncreasePercentage, "Bid increment percentage not met");
        require(addressToNumBids[msg.sender] < bidLimit, "Exceeded bid limit per address");

        highestBid = msg.value;
        highestBidder = msg.sender;
        numBids++;
        addressToNumBids[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 300) {
            auctionEndTime += 600; // Extend by 10 minutes
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}