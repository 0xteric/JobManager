// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract JobManager {
    struct Job {
        uint jobId;
        string title;
        string description;
        uint budget;
        uint deposit;
        address client;
        address selectedFreelancer;
        address admin;
        bool isOpen;
        bool isDone;
        address[] applicants;
        mapping(address => Application) applications;
    }

    struct Application {
        address freelancer;
        string proposal;
        uint proposalBudget;
        bool exists;
    }

    mapping(address => bool) public admins;
    mapping(uint => Job) public jobs;
    uint nextJobId;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not admin.");
        _;
    }

    constructor() {
        admins[msg.sender] = true;
    }

    event NewJob(uint jobId, address client, uint budget);
    event SelectedFreelancer(uint jobId, address freelancer);
    event CallAdmin(uint jobId, address caller);

    function postJob(string calldata title, string calldata description, uint budget) external {
        Job storage job = jobs[nextJobId];
        job.client = msg.sender;
        job.jobId = nextJobId;
        job.title = title;
        job.description = description;
        job.isOpen = true;
        job.isDone = false;
        job.budget = budget;
        emit NewJob(nextJobId, msg.sender, budget);
        nextJobId++;
    }

    function depositBudget(uint _jobId) external payable {
        Job storage job = jobs[_jobId];
        require(msg.sender == job.client, "Not allowed.");
        require(msg.value >= job.budget, "Not enough value.");
        job.deposit += msg.value;
    }

    function applyToJob(uint _jobId, string calldata _proposal, uint _proposalBudget) external {
        Job storage job = jobs[_jobId];
        require(job.isOpen, "Job is closed.");
        require(!job.applications[msg.sender].exists, "Already applied.");

        job.applicants.push(msg.sender);
        job.applications[msg.sender] = Application({freelancer: msg.sender, proposal: _proposal, proposalBudget: _proposalBudget, exists: true});
    }

    function selectFreelancer(uint _jobId, address _selectedFreelancer) external {
        Job storage job = jobs[_jobId];
        require(msg.sender == job.client, "Not allowed.");
        require(job.applications[_selectedFreelancer].exists, "Not exists.");

        job.selectedFreelancer = _selectedFreelancer;
        job.isOpen = false;
        emit SelectedFreelancer(_jobId, _selectedFreelancer);
    }

    function finishJob(uint jobId) external {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client, "Not allowed.");
        require(job.selectedFreelancer != address(0), "No freelancer selected.");
        require(!job.isDone, "Job already done");
        uint amount = job.deposit;
        job.deposit = 0;
        job.isDone = true;
        (bool success, ) = job.selectedFreelancer.call{value: amount}("");
        require(success, "Payment failed!");
    }

    function callAdmin(uint jobId) external {
        Job storage job = jobs[jobId];
        require(msg.sender == job.client || msg.sender == job.selectedFreelancer, "Not allowed");
        emit CallAdmin(jobId, msg.sender);
    }

    function addJobAdmin(uint jobId) external onlyAdmin {
        Job storage job = jobs[jobId];
        require(job.admin == address(0), "Job already has an admin.");
        job.admin = msg.sender;
    }

    function killJob(uint jobId) external onlyAdmin {
        Job storage job = jobs[jobId];
        require(job.admin == msg.sender, "Not allowed");
        uint amount = job.deposit;
        job.deposit = 0;
        job.isOpen = false;
        (bool success, ) = job.client.call{value: amount}("");
        require(success, "Transfer failed!");
    }

    function addAdmin(address _admin) external onlyAdmin {
        admins[_admin] = true;
    }

    function getJob(
        uint jobId
    )
        external
        view
        returns (
            uint jobId_,
            string memory title,
            string memory description,
            uint budget,
            uint deposit,
            address client,
            address selectedFreelancer,
            address admin,
            bool isOpen,
            bool isDone,
            address[] memory applicants
        )
    {
        Job storage job = jobs[jobId];
        return (job.jobId, job.title, job.description, job.budget, job.deposit, job.client, job.selectedFreelancer, job.admin, job.isOpen, job.isDone, job.applicants);
    }
}
