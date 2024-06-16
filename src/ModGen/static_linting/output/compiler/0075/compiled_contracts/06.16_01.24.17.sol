pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public totalTicketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => string) public userStatus;
    mapping(uint => address) public ticketOwner;
    mapping(uint => bool) public ticketTransferred;
    bool public eventCancelled = false;
    
    function buyTicket(uint _numTickets) public {
        require(_numTickets > 0 && _numTickets <= 3, "Invalid number of tickets");
        require(userTicketsPurchased[msg.sender] + _numTickets <= 3, "Exceeds ticket purchase limit");
        
        userTicketsPurchased[msg.sender] += _numTickets;
        totalTicketsAvailable -= _numTickets;
        
        for(uint i = 0; i < _numTickets; i++) {
            ticketOwner[totalTicketsAvailable + i] = msg.sender;
        }
    }
    
    function transferTicket(uint _ticketId, address _to) public {
        require(!eventCancelled, "Event has been cancelled");
        require(ticketOwner[_ticketId] == msg.sender, "You are not the owner of this ticket");
        require(userTicketsPurchased[_to] + 1 <= 3, "Recipient cannot hold more tickets");
        
        ticketOwner[_ticketId] = _to;
        userTicketsPurchased[msg.sender]--;
        userTicketsPurchased[_to]++;
        ticketTransferred[_ticketId] = true;
    }
    
    function cancelEvent() public {
        eventCancelled = true;
    }
    
    function calculateRefund(address _user) public view returns(uint) {
        require(eventCancelled, "Event has not been cancelled");
        
        uint numTicketsOwned = userTicketsPurchased[_user];
        uint refundAmount = numTicketsOwned * 100; // Placeholder calculation
        
        return refundAmount;
    }
}