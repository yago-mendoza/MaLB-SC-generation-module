// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrement;
    uint public minBidIncreasePercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public numTickets;
    uint public numBidsAllowed;
    
    mapping(address => uint) public numBidsByAddress;
    mapping(address => mapping(uint => uint)) public bidsByAddress;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _numTickets, uint _numBidsAllowed, uint _bidIncrement, uint _minBidIncreasePercentage) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        numTickets = _numTickets;
        numBidsAllowed = _numBidsAllowed;
        bidIncrement = _bidIncrement;
        minBidIncreasePercentage = _minBidIncreasePercentage;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() public payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid + bidIncrement, "Bid increment not met");
        require(numBidsByAddress[msg.sender] < numBidsAllowed, "Maximum number of bids reached for this address");
        
        if (block.timestamp + extensionDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        numBidsByAddress[msg.sender]++;
        bidsByAddress[msg.sender][numBidsByAddress[msg.sender]] = msg.value;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() public onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}