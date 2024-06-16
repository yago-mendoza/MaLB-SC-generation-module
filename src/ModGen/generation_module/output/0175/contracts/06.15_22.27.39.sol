```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public addressToNumBids;
    mapping(uint => address) public bidIndexToBidder;
    uint public numBids;
    
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        auctionEndTime = block.timestamp + _auctionDurationMinutes * 1 minutes;
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToNumBids[msg.sender] < 3, "Maximum 3 bids per address allowed");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        addressToNumBids[msg.sender]++;
        bidIndexToBidder[numBids] = msg.sender;
        numBids++;
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external {
        require(auctionEnded, "Auction has not ended yet");
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        
        // Transfer funds to the organizer
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external {
        require(!auctionEnded, "Auction has already ended");
        require(block.timestamp >= auctionEndTime, "Auction end time not reached");
        
        auctionEnded = true;
    }
}
```  