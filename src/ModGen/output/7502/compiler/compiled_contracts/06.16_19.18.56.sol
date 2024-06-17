// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public minBidAmount;
    uint public numBidsPerAddress;
    uint public totalBids;
    mapping(address => uint) public numBidsByAddress;
    mapping(uint => address) public bidIndexToAddress;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsPerAddress, uint _minBidAmount, uint _auctionDuration) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        minBidAmount = _minBidAmount;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + _auctionDuration;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= highestBid + minBidAmount, "Bid amount must be at least 5% higher than the current highest bid");
        require(numBidsByAddress[msg.sender] < numBidsPerAddress, "Maximum number of bids reached for this address");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        numBidsByAddress[msg.sender]++;
        totalBids++;
        bidIndexToAddress[totalBids] = msg.sender;
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}