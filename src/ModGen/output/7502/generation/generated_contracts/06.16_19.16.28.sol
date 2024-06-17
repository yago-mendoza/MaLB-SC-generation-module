// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public minBidIncrease;
    uint public auctionDuration;
    uint public finalBidLockTime;
    uint public extensionTime;
    uint public maxBidsPerAddress;
    uint public totalBids;
    bool public auctionEnded;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDuration, uint _bidIncrementPercentage, uint _extensionTime, uint _maxBidsPerAddress) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = _bidIncrementPercentage;
        minBidIncrease = 100 + _bidIncrementPercentage; // 100% + increment percentage
        extensionTime = _extensionTime;
        auctionDuration = _auctionDuration;
        finalBidLockTime = 5 minutes;
        maxBidsPerAddress = _maxBidsPerAddress;
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + (highestBid * minBidIncrease) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");
        
        totalBids++;
        addressBidCount[msg.sender]++;
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < finalBidLockTime) {
            auctionEndTime += extensionTime;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
    }
}