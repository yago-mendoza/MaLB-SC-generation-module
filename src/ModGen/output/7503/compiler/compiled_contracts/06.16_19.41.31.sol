// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    uint public auctionExtension;
    uint public minTokensRequired;
    uint public numBidsPerAddress;

    mapping(address => uint) public numBids;
    mapping(address => mapping(uint => uint)) public bids;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _auctionExtension, uint _minTokensRequired, uint _numBidsPerAddress, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        auctionDuration = _auctionDuration;
        auctionExtension = _auctionExtension;
        minTokensRequired = _minTokensRequired;
        numBidsPerAddress = _numBidsPerAddress;
        minBidIncreasePercentage = _minBidIncreasePercentage;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only auction organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether amount must match bid amount");
        require(_bidAmount >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtension;
        }

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        numBids[msg.sender]++;
        bids[msg.sender][numBids[msg.sender]] = _bidAmount;

        emit NewHighestBid(msg.sender, _bidAmount);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}