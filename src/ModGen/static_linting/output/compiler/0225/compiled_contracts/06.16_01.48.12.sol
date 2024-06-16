// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    
    struct Bid {
        address bidder;
        uint amount;
    }
    
    mapping(uint => Bid[]) public tokenBids;
    mapping(uint => uint) public highestBids;
    
    address public organizer;
    uint public auctionEndTime;
    uint public auctionDuration = 30 minutes;
    uint public extensionDuration = 10 minutes;
    
    event NewHighestBid(uint tokenId, uint amount, address bidder);
    
    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    function placeBid(uint tokenId) external payable {
        require(msg.value > 0, "Bid amount must be greater than 0");
        require(tokenBids[tokenId].length < 3, "Maximum 3 bids per token");
        
        uint currentHighestBid = highestBids[tokenId];
        uint minBidAmount = currentHighestBid + (currentHighestBid * 5 / 100);
        
        require(msg.value >= minBidAmount, "Bid amount must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        tokenBids[tokenId].push(Bid(msg.sender, msg.value));
        
        if (msg.value > currentHighestBid) {
            highestBids[tokenId] = msg.value;
            emit NewHighestBid(tokenId, msg.value, msg.sender);
        }
    }
    
    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw funds");
        
        uint totalBalance = address(this).balance;
        payable(organizer).transfer(totalBalance);
    }
    
    function getWinningBid(uint tokenId) public view returns (address, uint) {
        uint currentHighestBid = highestBids[tokenId];
        address winningBidder;
        uint winningBidAmount;
        
        for (uint i = 0; i < tokenBids[tokenId].length; i++) {
            if (tokenBids[tokenId][i].amount == currentHighestBid) {
                winningBidder = tokenBids[tokenId][i].bidder;
                winningBidAmount = tokenBids[tokenId][i].amount;
                break;
            }
        }
        
        return (winningBidder, winningBidAmount);
    }
}