// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public minBidIncreasePercentage;
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;

    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    mapping(uint => address) public bidIndexToAddress;
    uint public numBids = 0;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        
        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid must be at least 5% higher than current highest bid");

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        addressBidCount[msg.sender]++;
        numBids++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = msg.value;
        bidIndexToAddress[numBids] = msg.sender;
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction is still ongoing");

        payable(organizer).transfer(highestBid);
    }
}