```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;

    mapping(address => uint) public addressBidCount;
    mapping(address => uint[]) public addressBids;
    
    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        addressBids[msg.sender].push(msg.value);
        addressBidCount[msg.sender]++;
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}
```  