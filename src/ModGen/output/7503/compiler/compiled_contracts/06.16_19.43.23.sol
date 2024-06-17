// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsPerAddress;
    uint public totalBids;
    bool public auctionEnded;

    mapping(address => uint[]) public bidderBids;
    mapping(uint => address) public bidIndexToBidder;

    event NewHighestBid(address bidder, uint amount);

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsPerAddress, uint _auctionDurationMinutes) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + (_auctionDurationMinutes * 1 minutes);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() public payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(bidderBids[msg.sender].length < numBidsPerAddress, "Maximum number of bids reached");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes;
        }

        totalBids++;
        bidderBids[msg.sender].push(msg.value);
        bidIndexToBidder[totalBids] = msg.sender;
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() public onlyOrganizer {
        require(auctionEnded, "Auction has not ended yet");
        payable(organizer).transfer(highestBid);
    }

    function endAuction() public onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");
        auctionEnded = true;
    }
}