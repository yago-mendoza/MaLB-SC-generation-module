// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsAllowed;
    uint public constant bidIncrementPercentage = 5;
    uint public constant auctionDuration = 30 minutes;
    uint public constant bidLockDuration = 10 minutes;

    mapping(address => uint[]) public bidderBids;
    mapping(uint => address) public tokenBidder;

    event NewHighestBid(address bidder, uint bidAmount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsAllowed) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsAllowed = _numBidsAllowed;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether value must match bid amount");
        require(bidderBids[msg.sender].length < numBidsAllowed, "Exceeded maximum number of bids");
        require(_bidAmount >= highestBid + calculateBidIncrement(highestBid), "Bid amount must be at least 5% higher");

        if (block.timestamp + bidLockDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + bidLockDuration;
        }

        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);
        }

        bidderBids[msg.sender].push(_bidAmount);
        tokenBidder[ticketTokenId] = msg.sender;
    }

    function calculateBidIncrement(uint _currentBid) private view returns (uint) {
        return (_currentBid * bidIncrementPercentage) / 100;
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}