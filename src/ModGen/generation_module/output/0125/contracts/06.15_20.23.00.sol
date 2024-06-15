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

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    modifier auctionNotEnded() {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        _;
    }

    function placeBid(uint _bidAmount) external payable auctionNotEnded {
        require(msg.value == _bidAmount, "Sent Ether must match the bid amount");
        require(_bidAmount > highestBid, "Bid amount must be higher than current highest bid");
        require((_bidAmount * 100) / highestBid >= 105, "Bid must be at least 5% higher than the current highest bid");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids per address reached");

        highestBid = _bidAmount;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender]++;
        addressToBids[msg.sender][addressToBidCount[msg.sender]] = _bidAmount;

        emit NewHighestBid(msg.sender, _bidAmount);
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}
```