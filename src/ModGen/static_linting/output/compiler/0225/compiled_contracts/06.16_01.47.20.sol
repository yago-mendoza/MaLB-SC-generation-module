// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minTokensRequired;

    mapping(address => uint) public numBids;
    mapping(address => mapping(uint => uint)) public bidsByAddress;
    mapping(uint => address) public addressByBid;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _extensionDuration, uint _minTokensRequired) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minTokensRequired = _minTokensRequired;
        auctionEndTime = block.timestamp + auctionDuration;
        bidIncrementPercentage = 105; // 105 represents 5% increase
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(_bidAmount >= highestBid * bidIncrementPercentage / 100, "Bid amount must be at least 5% higher than the current highest bid");
        require(numBids[msg.sender] < 3, "Maximum 3 bids per address allowed");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }

        numBids[msg.sender]++;
        bidsByAddress[msg.sender][numBids[msg.sender]] = _bidAmount;
        addressByBid[_bidAmount] = msg.sender;

        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}