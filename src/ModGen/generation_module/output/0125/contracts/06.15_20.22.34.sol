```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public bidIncrementPercentage;
    uint public bidLimit;
    uint public totalBids;
    uint constant public auctionDuration = 30 minutes;
    uint constant public auctionExtensionDuration = 10 minutes;
    
    mapping(address => uint[]) public bidderBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketTokenId, uint _bidIncrementPercentage, uint _bidLimit) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
        ticketTokenId = _ticketTokenId;
        bidIncrementPercentage = _bidIncrementPercentage;
        bidLimit = _bidLimit;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(bidderBids[msg.sender].length < bidLimit, "Bidder has reached bid limit");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtensionDuration;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        totalBids++;
        bidderBids[msg.sender].push(msg.value);
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Perform transfer to organizer
        payable(organizer).transfer(highestBid);
    }
}
```