// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/JobManager.sol";

contract JobManagerTest is Test {
    JobManager public jobManager;

    address public admin;
    address public client;
    address public freelancer;
    address public anotherFreelancer;
    address public nonAdmin;

    event NewJob(uint jobId, address client, uint budget);
    event SelectedFreelancer(uint jobId, address freelancer);

    function setUp() public {
        jobManager = new JobManager();
        admin = makeAddr("admin");
        client = makeAddr("client");
        freelancer = makeAddr("freelancer");
        anotherFreelancer = makeAddr("anotherFreelancer");
        nonAdmin = makeAddr("nonAdmin");

        // Set up initial admins
        jobManager.addAdmin(admin);
    }

    // Test job creation
    function testPostJob() public {
        vm.prank(client);
        jobManager.postJob("Web3 Project", "Build a DEX", 1 ether);

        (uint jobId, , , uint budget, , address clientAddr, , , bool isOpen, , ) = jobManager.getJob(0);
        vm.assertEq(jobId, 0);
        assertEq(budget, 1 ether);
        assertEq(clientAddr, client);
        assertTrue(isOpen);
    }

    function testDepositBudget() public {
        vm.startPrank(client);
        vm.deal(client, 2 ether);
        jobManager.postJob("Foundry test", "Test deposit budget", 1 ether);
        jobManager.depositBudget{value: 1 ether}(0);
        vm.stopPrank();
        (, , , uint budget, uint deposit, , , , , , ) = jobManager.getJob(0);
        assertEq(deposit, 1 ether);
    }

    function testApplyToJob() public {
        testPostJob();
        vm.prank(freelancer);
        jobManager.applyToJob(0, "I'll build the next uniswap", 1 ether);
        (, , , , , , , , , , address[] memory applicants) = jobManager.getJob(0);
        assertEq(applicants.length, 1);
        assertEq(applicants[0], freelancer);
    }

    function testSelectFreelancer() public {
        testApplyToJob();
        vm.prank(client);
        jobManager.selectFreelancer(0, freelancer);
        (, , , , , , address selectedFreelancer, , , , ) = jobManager.getJob(0);
        assertEq(selectedFreelancer, freelancer);
    }

    function testFinishJob() public {
        testSelectFreelancer();
        vm.prank(client);
        jobManager.finishJob(0);
        (, , , , , , , , , bool isDone, ) = jobManager.getJob(0);
        assertTrue(isDone);
    }

    function testCallAdmin() public {
        testSelectFreelancer();
        vm.prank(client);
        jobManager.callAdmin(0);
    }

    function testAddJobAdmin() public {
        testSelectFreelancer();
        vm.prank(admin);
        jobManager.addJobAdmin(0);
        (, , , , , , , address _admin, , , ) = jobManager.getJob(0);
        assertEq(_admin, admin);
    }

    function testKillJob() public {
        testAddJobAdmin();
        vm.prank(admin);
        jobManager.killJob(0);
        (, , , , uint deposit, , , , bool isOpen, , ) = jobManager.getJob(0);
        assertEq(deposit, 0);
        assertTrue(!isOpen);
    }

    function testAddAdmin() public {
        jobManager.addAdmin(nonAdmin);
        assertTrue(jobManager.admins(nonAdmin));
    }
}
