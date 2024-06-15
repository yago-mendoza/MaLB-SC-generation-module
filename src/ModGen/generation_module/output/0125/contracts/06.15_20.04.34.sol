```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bidderToNumBids;
    mapping(uint => address) public bidIndexToBidder;
    uint public numBids;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    constructor(uint _biddingTime) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }
    
    function placeBid() external payable {
        require(msg.value > highestBid && msg.value >= (highestBid * 105) / 100, "Bid must be at least 5% higher than current highest bid");
        require(bidderToNumBids[msg.sender] < 3, "Maximum of 3 bids per address reached");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        
        if (bidderToNumBids[msg.sender] == 0) {
            bidIndexToBidder[numBids] = msg.sender;
            numBids++;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidderToNumBids[msg.sender]++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 300) {
            auctionEndTime += 600; // Extend auction by 10 minutes if bid in last 5 minutes
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
    
    function endAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
    }
}
```  