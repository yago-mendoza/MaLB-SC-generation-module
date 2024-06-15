```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public totalBids;

    mapping(address => uint) public addressBidCount;
    mapping(address => mapping(uint => uint)) public addressBids;

    event NewHighestBid(address bidder, uint amount);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    constructor(uint _auctionDuration) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
    }

    function placeBid(uint _bidAmount) external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(_bidAmount > highestBid && _bidAmount >= highestBid * 105 / 100, "Bid amount too low");

        totalBids++;
        addressBidCount[msg.sender]++;
        addressBids[msg.sender][addressBidCount[msg.sender]] = _bidAmount;

        if (addressBidCount[msg.sender] > 3) {
            revert("Maximum 3 bids per address allowed");
        }

        highestBid = _bidAmount;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, _bidAmount);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        require(highestBidder != address(0), "No bids have been placed");

        payable(organizer).transfer(highestBid);
    }
}
```