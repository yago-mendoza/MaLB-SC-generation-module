pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public ticketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => string) public userStatus;
    mapping(uint => address) public ticketOwners;
    uint public ticketsSold;
    bool public firstPhaseEnded;
    
    function purchaseTicket(uint _numTickets, string memory _status) public {
        require(_numTickets > 0, "Number of tickets must be greater than 0");
        require(_numTickets <= ticketsAvailable, "Not enough tickets available");
        require(userTicketsPurchased[msg.sender] + _numTickets <= 3 || keccak256(abi.encodePacked(_status)) != keccak256(abi.encodePacked("Golden")), "Golden status users can purchase up to 3 tickets");
        
        if (!firstPhaseEnded && ticketsSold + _numTickets > ticketsAvailable) {
            firstPhaseEnded = true;
        }
        
        ticketsSold += _numTickets;
        ticketsAvailable -= _numTickets;
        userTicketsPurchased[msg.sender] += _numTickets;
        userStatus[msg.sender] = _status;
        
        for (uint i = 0; i < _numTickets; i++) {
            ticketOwners[ticketsSold - _numTickets + i] = msg.sender;
        }
    }
    
    function transferTicket(uint _ticketId, address _to) public {
        require(ticketOwners[_ticketId] == msg.sender, "You do not own this ticket");
        require(keccak256(abi.encodePacked(userStatus[msg.sender])) == keccak256(abi.encodePacked("Golden")), "Only Golden status users can transfer tickets");
        
        ticketOwners[_ticketId] = _to;
        userTicketsPurchased[msg.sender]--;
        userTicketsPurchased[_to]++;
    }
    
    function refundTicket(uint _ticketId) public {
        require(ticketOwners[_ticketId] == msg.sender, "You do not own this ticket");
        
        ticketsAvailable++;
        ticketsSold--;
        userTicketsPurchased[msg.sender]--;
        ticketOwners[_ticketId] = address(0);
    }
}