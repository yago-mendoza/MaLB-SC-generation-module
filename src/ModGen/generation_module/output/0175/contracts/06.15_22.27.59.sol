```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsAllowed;
    uint public bidCount;
    bool public auctionEnded;
    
    mapping(address => uint[]) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsAllowed, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsAllowed = _numBidsAllowed;
        auctionEndTime = block.timestamp + (_auctionDurationMinutes * 1 minutes);
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(bidderBids[msg.sender].length < numBidsAllowed, "Maximum number of bids reached");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid in last 5 minutes
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidderBids[msg.sender].push(msg.value);
        bidCount++;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Perform transfer to organizer
        // organizer.transfer(highestBid); // Uncomment this line and replace 'organizer' with actual address
    }
    
    function endAuction() external {
        require(!auctionEnded, "Auction has already ended");
        require(block.timestamp >= auctionEndTime, "Auction time not reached");
        
        auctionEnded = true;
        // Perform any additional logic for determining winning bid, token transfer, etc.
    }
}
```  