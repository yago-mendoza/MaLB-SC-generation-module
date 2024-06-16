pragma solidity ^0.8.0;

contract TokenSaleManagement {
    uint public ticketsAvailable = 50000;
    mapping(address => uint) public userTicketsPurchased;
    mapping(address => uint) public userTicketsTransferred;
    mapping(address => string) public userStatus;
    uint public goldenTransferLimit = 3;
    uint public platinumTransferLimit = 1;
    uint public bronzeTransferLimit = 1;
    bool public secondPhaseTriggered = false;
    bool public eventCancelled = false;
    
    function buyTicket(uint _numTickets) public {
        require(_numTickets > 0 && _numTickets <= ticketsAvailable, "Invalid number of tickets");
        require(userTicketsPurchased[msg.sender] + _numTickets <= 1, "Exceeded ticket purchase limit");
        
        if(keccak256(abi.encodePacked(userStatus[msg.sender])) == keccak256(abi.encodePacked("Golden"))) {
            require(userTicketsPurchased[msg.sender] + _numTickets <= goldenTransferLimit, "Exceeded Golden status transfer limit");
        }
        
        ticketsAvailable -= _numTickets;
        userTicketsPurchased[msg.sender] += _numTickets;
        
        if(ticketsAvailable == 0 && !secondPhaseTriggered) {
            secondPhaseTriggered = true;
        }
    }
    
    function transferTicket(address _to, uint _numTickets) public {
        require(_numTickets > 0 && _numTickets <= userTicketsPurchased[msg.sender], "Invalid number of tickets to transfer");
        require(userTicketsTransferred[_to] + _numTickets <= 1, "Recipient exceeded ticket transfer limit");
        
        if(keccak256(abi.encodePacked(userStatus[msg.sender])) == keccak256(abi.encodePacked("Golden"))) {
            require(userTicketsTransferred[_to] + _numTickets <= goldenTransferLimit, "Recipient exceeded Golden status transfer limit");
        }
        
        userTicketsPurchased[msg.sender] -= _numTickets;
        userTicketsTransferred[_to] += _numTickets;
    }
    
    function cancelEvent() public {
        eventCancelled = true;
    }
    
    function calculateRefund() public view returns(uint) {
        // Calculation logic for refund and compensation
    }
}