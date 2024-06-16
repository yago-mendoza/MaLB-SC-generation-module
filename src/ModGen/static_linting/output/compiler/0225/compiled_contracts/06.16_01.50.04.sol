pragma solidity ^0.8.0;

contract VIPAuction {
    address public organizer;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public bidIncrementPercentage;
    uint public auctionDuration;
    uint public extensionDuration;
    uint public minBidIncrease;
    uint public numTokensRequired;
    
    mapping(address => uint) public addressToBidCount;
    
    event NewHighestBid(address bidder, uint amount);
    
    constructor(uint _auctionDuration, uint _extensionDuration, uint _minBidIncrease, uint _numTokensRequired) {
        organizer = msg.sender;
        auctionDuration = _auctionDuration;
        extensionDuration = _extensionDuration;
        minBidIncrease = _minBidIncrease;
        numTokensRequired = _numTokensRequired;
        auctionEndTime = block.timestamp + auctionDuration;
    }
    
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only organizer can call this function");
        _;
    }
    
    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= numTokensRequired, "Minimum tokens required to participate");
        require(addressToBidCount[msg.sender] < 3, "Maximum 3 bids allowed per address");
        
        uint currentBid = addressToBidCount[msg.sender];
        require(msg.value >= highestBid + (highestBid * minBidIncrease / 100), "Bid must be at least 5% higher than current highest bid");
        
        if (block.timestamp >= auctionEndTime - 5 minutes) {
            auctionEndTime += extensionDuration;
        }
        
        highestBid = msg.value;
        highestBidder = msg.sender;
        addressToBidCount[msg.sender] = currentBid + 1;
        
        emit NewHighestBid(msg.sender, msg.value);
    }
    
    function withdraw() external onlyOrganizer {
        require(block.timestamp >= auctionEndTime, "Auction is still ongoing");
        
        payable(organizer).transfer(highestBid);
    }
}