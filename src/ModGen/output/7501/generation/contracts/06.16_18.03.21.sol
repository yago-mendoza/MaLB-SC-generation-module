// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public auctionDuration;
    uint public bufferDuration;
    uint public numBidsAllowed;
    mapping(address => uint) public numBidsPlaced;
    mapping(address => uint[]) public bidsByAddress;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _bufferDuration, uint _numBidsAllowed, uint _bidIncrementPercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        auctionDuration = _auctionDuration;
        bufferDuration = _bufferDuration;
        numBidsAllowed = _numBidsAllowed;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidIncrease = 100 + _bidIncrementPercentage;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require((msg.value * 100) >= (highestBid * minBidIncrease), "Bid amount must be at least 5% higher than the current highest bid");
        require(numBidsPlaced[msg.sender].length < numBidsAllowed, "Maximum number of bids reached for this address");

        if (block.timestamp > auctionEndTime - bufferDuration) {
            auctionEndTime += bufferDuration;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        numBidsPlaced[msg.sender].push(msg.value);

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function getHighestBid() external view returns (uint) {
        return highestBid;
    }

    function getHighestBidder() external view returns (address) {
        return highestBidder;
    }
}