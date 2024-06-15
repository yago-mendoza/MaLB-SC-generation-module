```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minBidIncrease;
    uint public minTokenRequired;
    uint public numBidsPerAddress;
    
    mapping(address => uint[]) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _minBidIncrease, uint _minTokenRequired) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        bidIncrementPercentage = _minBidIncrease;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minBidIncrease = _minBidIncrease;
        minTokenRequired = _minTokenRequired;
        numBidsPerAddress = 3;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= highestBid + minBidIncrease, "Bid amount too low");
        require(addressBids[msg.sender].length < numBidsPerAddress, "Exceeded max bids per address");
        
        if (block.timestamp + extensionDuration > auctionEndTime) {
            auctionEndTime = block.timestamp + extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressBids[msg.sender].push(msg.value);
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```