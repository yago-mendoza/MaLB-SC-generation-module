// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public totalBids;
    mapping(address => uint) public addressBidCount;
    mapping(uint => address) public bidIndexToAddress;
    mapping(address => uint) public addressToBidIndex;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _auctionDuration, uint _ticketTokenId) {
        organizer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        ticketTokenId = _ticketTokenId;
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(totalBids < 3, "Maximum bids reached");
        require(msg.value > highestBid * 105 / 100, "Bid must be at least 5% higher than current highest bid");

        totalBids++;
        addressBidCount[msg.sender]++;
        highestBid = msg.value;
        highestBidder = msg.sender;
        bidIndexToAddress[totalBids] = msg.sender;
        addressToBidIndex[msg.sender] = totalBids;

        emit NewHighestBid(msg.sender, msg.value);

        if (block.timestamp + 5 minutes > auctionEndTime) {
            auctionEndTime = block.timestamp + 10 minutes;
        }
    }

    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }
}