```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minimumBidIncreasePercentage;
    uint public bidLimitPerAddress;
    uint public totalBids;
    bool public auctionEnded;
    
    mapping(address => uint) public addressBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _ticketTokenId, uint _minimumBidIncreasePercentage, uint _bidLimitPerAddress) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
        minimumBidIncreasePercentage = _minimumBidIncreasePercentage;
        bidLimitPerAddress = _bidLimitPerAddress;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    modifier onlyDuringAuction() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }
    
    function placeBid() external payable onlyDuringAuction {
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + minimumBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < bidLimitPerAddress, "Exceeded bid limit per address");
        
        totalBids++;
        addressBidCount[msg.sender]++;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(!auctionEnded, "Withdrawal already processed");
        
        auctionEnded = true;
        // Perform transfer of highest bid amount to organizer
        payable(organizer).transfer(highestBid);
    }
}
```