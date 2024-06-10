
pragma solidity ^0.8.0;

contract TicketSaleManagement {
    uint public totalTicketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => uint) public userTicketsTransferred;
    mapping(address => string) public userStatus;
    mapping(uint => address) public ticketOwners;
    mapping(uint => bool) public ticketTransferred;
    bool public eventCancelled = false;
    
    function purchaseTicket(uint _numTickets) external {
        require(userTicketsPurchased[msg.sender] + _numTickets <= 3 || keccak256(abi.encodePacked(userStatus[msg.sender])) == keccak256(abi.encodePacked("Golden")), "Ticket purchase limit exceeded");
        require(totalTicketsAvailable >= _numTickets, "Not enough tickets available");
        
        userTicketsPurchased[msg.sender] += _numTickets;
        totalTicketsAvailable -= _numTickets;
        
        if(keccak256(abi.encodePacked(userStatus[msg.sender])) == keccak256(abi.encodePacked("Golden"))) {
            require(userTicketsTransferred[msg.sender] + _numTickets <= 3, "Golden status transfer limit exceeded");
        }
        
        for(uint i = 0; i < _numTickets; i++) {
            ticketOwners[i] = msg.sender;
        }
    }
    
    function transferTicket(address _to, uint _ticketId) external {
        require(ticketOwners[_ticketId] == msg.sender, "You are not the owner of this ticket");
        require(eventCancelled == false, "Event is cancelled, ticket transfer not allowed");
        require(keccak256(abi.encodePacked(userStatus[msg.sender])) == keccak256(abi.encodePacked("Golden")), "Only Golden status users can transfer tickets");
        
        ticketOwners[_ticketId] = _to;
        userTicketsTransferred[msg.sender]++;
        ticketTransferred[_ticketId] = true;
    }
    
    function cancelEvent() external {
        eventCancelled = true;
    }
    
    function calculateCompensation(address _ticketHolder) public view returns (uint) {
        require(eventCancelled == true, "Event is not cancelled");
        
        if(keccak256(abi.encodePacked(userStatus[_ticketHolder])) == keccak256(abi.encodePacked("Golden"))) {
            return 25; // 25% extra compensation for Golden status users
        } else if(keccak256(abi.encodePacked(userStatus[_ticketHolder])) == keccak256(abi.encodePacked("Platinum"))) {
            return 5; // 5% extra compensation for Platinum status users
        } else {
            return 0; // No extra compensation for Bronze status users
        }
    }
}
