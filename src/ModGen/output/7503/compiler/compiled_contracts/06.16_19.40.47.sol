// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public addressBidCount;
    mapping(address => uint[3]) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= (highestBid * 105) / 100, "Bid must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        addressBidCount[msg.sender]++;
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
            
            if (auctionEndTime - block.timestamp < 300) { // Less than 5 minutes remaining
                auctionEndTime = block.timestamp + 600; // Extend by 10 minutes
            }
        }
        
        for (uint i = 0; i < 3; i++) {
            if (addressBids[msg.sender][i] == 0) {
                addressBids[msg.sender][i] = msg.value;
                break;
            }
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp > auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}