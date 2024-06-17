// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketToken;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    uint public auctionExtension;
    uint public numBidsPerAddress;
    uint public totalBids;

    mapping(address => uint) public numBids;
    mapping(address => mapping(uint => uint)) public bids;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketToken, uint _minBidIncreasePercentage, uint _auctionDuration, uint _auctionExtension, uint _numBidsPerAddress) {
        organizer = msg.sender;
        ticketToken = _ticketToken;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        auctionDuration = _auctionDuration;
        auctionExtension = _auctionExtension;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent value must equal bid amount");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");

        if (totalBids > 0) {
            require(_bidAmount >= highestBid + (highestBid * minBidIncreasePercentage / 100), "Bid amount must be at least 5% higher than current highest bid");
        } else {
            require(_bidAmount > 0, "Initial bid must be greater than 0");
        }

        totalBids++;
        numBids[msg.sender]++;
        bids[msg.sender][numBids[msg.sender]] = _bidAmount;

        if (_bidAmount > highestBid) {
            highestBid = _bidAmount;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, _bidAmount);

            if (auctionEndTime - block.timestamp < auctionExtension) {
                auctionEndTime = block.timestamp + auctionExtension;
            }
        }
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}