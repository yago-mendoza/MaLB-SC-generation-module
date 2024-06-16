// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionExtension;
    uint public numBidsPerAddress;
    uint public minTokensRequired;

    mapping(address => uint) public numBidsByAddress;
    mapping(uint => address) public bidders;
    mapping(address => uint) public bids;

    event NewHighestBid(address bidder, uint bidAmount);

    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionExtension, uint _numBidsPerAddress, uint _minTokensRequired) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction duration to 1 hour
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionExtension = _auctionExtension;
        numBidsPerAddress = _numBidsPerAddress;
        minTokensRequired = _minTokensRequired;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= highestBid + (highestBid * bidIncrementPercentage / 100), "Bid amount must be at least 5% higher than current highest bid");
        require(numBidsByAddress[msg.sender] < numBidsPerAddress, "Maximum number of bids reached for this address");

        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtension;
        }

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        numBidsByAddress[msg.sender]++;
        bidders[numBidsByAddress[msg.sender]] = msg.sender;
        bids[msg.sender] = msg.value;
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}