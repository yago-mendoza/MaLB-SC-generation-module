```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    mapping(address => mapping(uint => uint)) public addressToBids;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Incorrect bid amount sent");
        require(_bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require((_bidAmount - highestBid) * 100 / highestBid >= 5, "Bid must be at least 5% higher");
        require(addressToBidCount[msg.sender] < 3, "Maximum of 3 bids per address reached");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = _bidAmount;
        addressToBidCount[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```