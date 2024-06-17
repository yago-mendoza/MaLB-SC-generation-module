// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    
    mapping(address => uint) public addressToBidCount;
    mapping(uint => address) public bidIndexToBidder;
    uint public numBids;
    
    bool public auctionEnded;
    
    event NewHighestBid(address bidder, uint amount);
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }
    
    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }
    
    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(block.timestamp < auctionEndTime, "Auction time has expired");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        require(msg.value > highestBid * 105 / 100, "Bid must be at least 5% higher than the current highest bid");
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        bidIndexToBidder[numBids] = msg.sender;
        numBids++;
        
        emit NewHighestBid(msg.sender, msg.value);
        
        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }
    
    function withdraw() external onlyOrganizer {
        require(auctionEnded, "Auction has not ended");
        
        auctionEnded = true;
        // Perform transfer of highestBid to organizer
    }
    
    function finalizeAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        
        auctionEnded = true;
        // Perform finalization tasks like transfer of ticket token, etc.
    }
}