pragma solidity ^0.8.0;

contract TicketSaleManagement {
    uint public totalTicketsAvailable = 50000;
    uint public ticketsSold;
    uint public goldenTicketsPurchased;
    uint public platinumTicketsPurchased;
    uint public bronzeTicketsPurchased;
    
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => bool) public isGoldenUser;
    
    enum TicketStatus { Unsold, Sold, Refunded }
    mapping(uint => TicketStatus) public ticketStatus;
    
    event TicketPurchased(address user, uint ticketsPurchased);
    event TicketTransferred(address from, address to, uint ticketsTransferred);
    event TicketRefunded(address user, uint ticketsRefunded);
    
    function purchaseTickets(uint _numTickets) public {
        require(_numTickets > 0, "Number of tickets must be greater than 0");
        require(_numTickets <= 3 || !isGoldenUser[msg.sender], "Golden users can purchase up to 3 tickets");
        require(userTicketsPurchased[msg.sender] + _numTickets <= 3 || !isGoldenUser[msg.sender], "Ticket purchase limit exceeded");
        require(ticketsSold + _numTickets <= totalTicketsAvailable, "Not enough tickets available");
        
        ticketsSold += _numTickets;
        userTicketsPurchased[msg.sender] += _numTickets;
        
        if (isGoldenUser[msg.sender]) {
            goldenTicketsPurchased += _numTickets;
        } else {
            if (_numTickets == 1) {
                bronzeTicketsPurchased++;
            } else {
                platinumTicketsPurchased++;
            }
        }
        
        emit TicketPurchased(msg.sender, _numTickets);
    }
    
    function transferTickets(address _to, uint _numTickets) public {
        require(_numTickets > 0, "Number of tickets must be greater than 0");
        require(_numTickets <= 3 || !isGoldenUser[msg.sender], "Golden users can transfer up to 3 tickets");
        require(userTicketsPurchased[msg.sender] >= _numTickets, "Not enough tickets to transfer");
        
        userTicketsPurchased[msg.sender] -= _numTickets;
        userTicketsPurchased[_to] += _numTickets;
        
        emit TicketTransferred(msg.sender, _to, _numTickets);
    }
    
    function refundTickets(uint _numTickets) public {
        require(_numTickets > 0, "Number of tickets must be greater than 0");
        require(userTicketsPurchased[msg.sender] >= _numTickets, "Not enough tickets to refund");
        
        userTicketsPurchased[msg.sender] -= _numTickets;
        ticketsSold -= _numTickets;
        
        emit TicketRefunded(msg.sender, _numTickets);
    }
}