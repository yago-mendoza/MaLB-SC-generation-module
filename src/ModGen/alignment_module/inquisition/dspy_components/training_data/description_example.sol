// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAO {
    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        uint startTime;
        uint endTime;
        bool executed;
        mapping(address => bool) voted;
    }

    address public admin;
    uint public proposalCount;
    uint public quorum;
    uint public votingDuration;

    mapping(uint => Proposal) public proposals;
    mapping(address => bool) public members;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only members can call this function.");
        _;
    }

    event ProposalCreated(uint id, string description, uint startTime, uint endTime);
    event Voted(uint proposalId, address voter);
    event ProposalExecuted(uint proposalId);

    constructor(uint _quorum, uint _votingDuration) {
        admin = msg.sender;
        quorum = _quorum;
        votingDuration = _votingDuration;
    }

    function addMember(address _member) public onlyAdmin {
        members[_member] = true;
    }

    function createProposal(string memory _description) public onlyMember {
        proposalCount++;
        uint startTime = block.timestamp;
        uint endTime = block.timestamp + votingDuration;

        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = _description;
        newProposal.startTime = startTime;
        newProposal.endTime = endTime;
        newProposal.executed = false;

        emit ProposalCreated(proposalCount, _description, startTime, endTime);
    }

    function vote(uint _proposalId) public onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.startTime, "Voting not started yet.");
        require(block.timestamp <= proposal.endTime, "Voting period has ended.");
        require(!proposal.voted[msg.sender], "Already voted.");

        proposal.voted[msg.sender] = true;
        proposal.voteCount++;

        emit Voted(_proposalId, msg.sender);
    }

    function executeProposal(uint _proposalId) public onlyAdmin {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.endTime, "Voting period not ended yet.");
        require(!proposal.executed, "Proposal already executed.");
        require(proposal.voteCount >= quorum, "Quorum not reached.");

        proposal.executed = true;

        // Implement proposal execution logic here.

        emit ProposalExecuted(_proposalId);
    }

    function isMember(address _address) public view returns (bool) {
        return members[_address];
    }

    function getProposal(uint _proposalId) public view returns (uint, string memory, uint, uint, uint, bool) {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.id,
            proposal.description,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed
        );
    }
}