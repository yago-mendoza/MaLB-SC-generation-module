// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public auctionExtension;
    uint public numBidsAllowed;
    mapping(address => uint) public numBidsByAddress;
    mapping(uint => address) public bidders;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _auctionDuration, uint _auctionExtension, uint _numBidsAllowed) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        auctionDuration = _auctionDuration;
        auctionExtension = _auctionExtension;
        numBidsAllowed = _numBidsAllowed;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can perform this action");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + bidIncrementPercentage) / 100, "Bid increment percentage not met");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Maximum number of bids reached");
        
        if (block.timestamp > auctionEndTime - auctionExtension) {
            auctionEndTime += auctionExtension;
        }
        
        numBidsByAddress[msg.sender]++;
        if (numBidsByAddress[msg.sender] == 1) {
            bidders[highestBid] = msg.sender;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}