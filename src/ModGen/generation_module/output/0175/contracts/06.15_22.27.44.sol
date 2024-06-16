```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint constant public minBidIncreasePercentage = 5;
    uint constant public maxBidsPerAddress = 3;
    
    mapping(address => uint) public addressToNumBids;
    mapping(address => mapping(uint => uint)) public addressToBidAmount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionEndTime, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = _auctionEndTime;
        ticketTokenId = _ticketTokenId;
    }
    
    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value == _bidAmount, "Sent Ether must match bid amount");
        require(_bidAmount > highestBid + (highestBid * minBidIncreasePercentage) / 100, "Bid amount must be at least 5% higher than current highest bid");
        require(addressToNumBids[msg.sender] < maxBidsPerAddress, "Exceeded maximum number of bids per address");
        
        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressToBidAmount[msg.sender][addressToNumBids[msg.sender]] = _bidAmount;
        addressToNumBids[msg.sender]++;
        
        emit NewHighestBid(msg.sender, _bidAmount);
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        // Transfer funds to organizer
        payable(organizer).transfer(highestBid);
    }
}
```