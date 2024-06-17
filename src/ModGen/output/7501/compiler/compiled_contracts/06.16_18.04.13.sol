// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedVIPTicketAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public ticketTokenId;
    uint public minBidIncreasePercentage;
    uint public numBidsPerAddress;
    uint public constant MAX_BIDS_PER_ADDRESS = 3;
    uint public constant BID_INCREMENT_PERCENTAGE = 5;
    bool public auctionEnded;
    bool public withdrawCalled;

    event NewHighestBid(address bidder, uint amount);

    mapping(address => uint) public numBids;
    mapping(address => uint[MAX_BIDS_PER_ADDRESS]) public bids;

    constructor(uint _ticketTokenId, uint _minBidIncreasePercentage, uint _numBidsPerAddress) {
        organizer = msg.sender;
        ticketTokenId = _ticketTokenId;
        minBidIncreasePercentage = _minBidIncreasePercentage;
        numBidsPerAddress = _numBidsPerAddress;
        auctionEndTime = block.timestamp + 1 hours; // Set initial auction time to 1 hour
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the organizer can call this function");
        _;
    }

    function placeBid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");
        require(numBids[msg.sender] < numBidsPerAddress, "Exceeded maximum number of bids per address");

        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += 10 minutes; // Extend auction by 10 minutes if bid is within last 5 minutes
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        numBids[msg.sender]++;
        bids[msg.sender][numBids[msg.sender] - 1] = msg.value;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external onlyOrganizer {
        require(!withdrawCalled, "Withdraw already called");
        require(auctionEnded, "Auction has not ended yet");

        withdrawCalled = true;
        // Implement transfer of highest bid amount to organizer
        payable(organizer).transfer(highestBid);
    }

    function endAuction() external onlyOrganizer {
        require(!auctionEnded, "Auction has already ended");

        auctionEnded = true;
        // Perform any finalization logic here
    }
}