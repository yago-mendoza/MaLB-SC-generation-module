// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    uint public lastBidTime;
    uint public auctionExtension = 600; // 10 minutes in seconds

    mapping(address => uint) public addressBidCount;
    mapping(address => uint[]) public addressBids;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _auctionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionDuration = _auctionDuration;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can perform this action");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address allowed");

        // Update bid information
        highestBid = msg.value;
        highestBidder = msg.sender;
        lastBidTime = block.timestamp;
        addressBids[msg.sender].push(msg.value);
        addressBidCount[msg.sender]++;

        emit NewHighestBid(msg.sender, msg.value);

        if (block.timestamp + 300 > auctionEndTime) {
            // If bid is placed within last 5 minutes, extend auction by 10 minutes
            auctionEndTime = block.timestamp + auctionExtension;
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function getBidCount(address bidder) external view returns (uint) {
        return addressBidCount[bidder];
    }

    function getBidAmount(address bidder, uint index) external view returns (uint) {
        return addressBids[bidder][index];
    }
}