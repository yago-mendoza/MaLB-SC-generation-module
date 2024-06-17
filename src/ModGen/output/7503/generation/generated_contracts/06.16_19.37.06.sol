// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public maxBidsPerAddress = 3;
    uint constant public auctionDuration = 60; // 1 hour
    uint constant public bidLockDuration = 5 * 60; // 5 minutes
    uint constant public auctionExtensionDuration = 10 * 60; // 10 minutes

    mapping(address => uint) public addressBidCount;
    mapping(address => uint[]) public addressBids;
    mapping(uint => address) public bidToBidder;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher");

        if (block.timestamp > auctionEndTime - bidLockDuration) {
            auctionEndTime += auctionExtensionDuration;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        addressBids[msg.sender].push(msg.value);
        bidToBidder[msg.value] = msg.sender;
        addressBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}