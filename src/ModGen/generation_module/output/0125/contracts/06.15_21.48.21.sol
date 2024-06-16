```solidity
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
    uint public extensionDuration;
    uint public minTokensRequired;
    uint public totalTokens;
    
    mapping(address => uint) public bidsPerAddress;
    mapping(address => mapping(uint => uint)) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _minTokensRequired) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minTokensRequired = _minTokensRequired;
        auctionEndTime = block.timestamp + _auctionDuration;
        highestBid = 0;
        bidIncrementPercentage = 5;
        minBidIncrease = 0;
        totalTokens = 0;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    function placeBid(uint _tokenID) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minTokensRequired, "Minimum tokens required to participate");
        require(bidsPerAddress[msg.sender] < 3, "Maximum 3 bids per address");
        
        uint currentBid = addressBids[msg.sender][_tokenID];
        uint minBidAmount = highestBid + ((highestBid * minBidIncrease) / 100);
        
        require(msg.value >= minBidAmount, "Bid amount must be at least 5% higher than the current highest bid");
        
        if (msg.value > currentBid) {
            totalTokens += msg.value - currentBid;
            addressBids[msg.sender][_tokenID] = msg.value;
            bidsPerAddress[msg.sender]++;
            
            if (msg.value > highestBid) {
                highestBid = msg.value;
                highestBidder = msg.sender;
                auctionEndTime = block.timestamp + extensionDuration;
                emit NewHighestBid(msg.sender, msg.value);
            }
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```  