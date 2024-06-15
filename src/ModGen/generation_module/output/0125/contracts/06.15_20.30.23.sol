```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public totalBids;

    mapping(address => uint) public addressBidCount;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _biddingTime) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid increment must be at least 5%");

        totalBids++;
        require(addressBidCount[msg.sender] < 3, "Maximum 3 bids per address");
        addressBidCount[msg.sender]++;

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);

        if (auctionEndTime - block.timestamp < 5 minutes) {
            auctionEndTime += 10 minutes;
        }
    }

    function withdraw() external {
        require(msg.sender == organizer, "Only organizer can withdraw");
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        payable(organizer).transfer(highestBid);
    }
}
```