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

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _biddingTime) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
        ticketTokenId = _ticketTokenId;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than current highest bid");
        require(msg.value >= highestBid * 105 / 100, "Bid amount must be at least 5% higher");

        address sender = msg.sender;
        require(addressToBidCount[sender] < 3, "Maximum 3 bids per address");

        if (msg.value > highestBid) {
            highestBid = msg.value;
            highestBidder = sender;
            emit NewHighestBid(sender, msg.value);
        }

        addressToBidCount[sender]++;
        bidIndexToBidder[highestBid] = sender;
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");

        // Withdraw the highest bid amount to the organizer
        payable(organizer).transfer(highestBid);
    }
}