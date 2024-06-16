```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public addressBidCount;
    mapping(address => uint[]) public addressBids;
    uint public constant maxBidsPerAddress = 3;
    uint public constant minBidIncreasePercentage = 5;
    uint public constant auctionDuration = 30 minutes;
    uint public constant auctionExtension = 10 minutes;

    event NewHighestBid(address bidder, uint amount);

    constructor() {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + auctionDuration;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid * (100 + minBidIncreasePercentage) / 100, "Bid increase must be at least 5%");

        if (block.timestamp > auctionEndTime - 5 minutes) {
            auctionEndTime += auctionExtension;
        }

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = msg.sender;
            emit NewHighestBid(msg.sender, msg.value);
        }

        addressBids[msg.sender].push(msg.value);
        addressBidCount[msg.sender]++;

        require(addressBidCount[msg.sender] <= maxBidsPerAddress, "Exceeded maximum bid count per address");
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only the organizer can withdraw funds");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        
        payable(organizer).transfer(highestBid);
    }
}
```  