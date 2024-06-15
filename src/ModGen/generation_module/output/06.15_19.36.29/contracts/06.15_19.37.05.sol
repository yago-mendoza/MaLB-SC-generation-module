```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public ticketId;
    uint public timeLimit;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _ticketId, uint _timeLimit) {
        organizer = msg.sender;
        ticketId = _ticketId;
        timeLimit = _timeLimit;
        auctionEndTime = block.timestamp + _timeLimit;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether must match bid amount");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(_bidAmount > highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressBidCount[msg.sender]++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;
        
        emit NewHighestBid(msg.sender, _bidAmount);
        
        if (auctionEndTime - block.timestamp < 300) {
            auctionEndTime += 600; // Extend auction by 10 minutes if bid placed within last 5 minutes
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(auctionEnded, "Auction has not ended yet");
        
        auctionEnded = true;
        // Perform fund transfer to organizer
    }
    
    function finalizeAuction() external {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        auctionEnded = true;
        // Finalize auction, transfer funds to organizer
    }
}
```