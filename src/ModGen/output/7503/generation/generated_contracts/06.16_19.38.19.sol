// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public minBidAmount;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public numTokensRequired;
    uint public numBidsPerAddress;

    mapping(address => uint) public numBids;
    mapping(address => mapping(uint => uint)) public bidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _bidIncrement, uint _minBidAmount, uint _auctionDuration, uint _extensionDuration, uint _numTokensRequired, uint _numBidsPerAddress) {
        organizer = msg.sender;
        bidIncrement = _bidIncrement;
        minBidAmount = _minBidAmount;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numTokensRequired = _numTokensRequired;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minBidAmount, "Bid amount is below minimum");
        require(msg.value >= highestBid + bidIncrement, "Bid amount must be at least 5% higher than the current highest bid");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        numBids[msg.sender]++;
        bidsByAddress[msg.sender][numBids[msg.sender]] = msg.value;
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction is still ongoing");
        payable(organizer).transfer(highestBid);
    }
}