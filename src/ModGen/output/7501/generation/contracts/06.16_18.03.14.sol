// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketToken;
    
    mapping(address => uint) public addressBidCount;
    mapping(address => uint[]) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _ticketToken) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketToken = _ticketToken;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Exceeded maximum bid count per address");
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressBidCount[msg.sender]++;
        addressBids[msg.sender].push(msg.value);
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 300) {
            auctionEndTime += 600; // Extend auction by 10 minutes if bid placed in last 5 minutes
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}