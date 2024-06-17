// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressToBidCount;
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _biddingTime) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        
        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }
        
        addressToBidCount[msg.sender]++;
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction is not over yet");
        
        (bool success, ) = organizer.call{value: highestBid}("");
        require(success, "Transfer failed");
        
        highestBid = 0;
        auctionEnded = true;
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        (bool success, ) = organizer.call{value: highestBid}("");
        require(success, "Transfer failed");
        
        auctionEnded = true;
    }
}