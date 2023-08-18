//SPDX-License-Identifier:Mit
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMeContract} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    function setUp() external{
        DeployFundMeContract deployFundMeContract = new DeployFundMeContract();
        fundMe = deployFundMeContract.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() public {
        console.log(msg.sender);
        console.log(fundMe.getOwner());
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE}();
        uint256 fundedAmount = fundMe.getFundedAmountToFundedAddress(USER);
        assertEq(fundedAmount, 0.1 ether);
    }
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE}();
        address funderAdd = fundMe.getFunderAddress(0);
        assertEq(funderAdd, USER);
    }
    function testWithdrawByOwnerOnly() public {
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE}();
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value : SEND_VALUE}();
        _;
    }
    function testWithdrawWithAsingleFunder() public funded {
        uint256 startingOwnerBal = fundMe.getOwner().balance;
        uint256 startingFundMeBal = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBal = fundMe.getOwner().balance;
        uint256 endingFundMeBal = address(fundMe).balance;
        assertEq(endingFundMeBal, 0);
        assertEq(startingOwnerBal+startingFundMeBal, endingOwnerBal);
    }
    function testWithdrawFromMultipleFunders() public{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++)
        {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value : SEND_VALUE}();
        }
        uint256 startingOwnerBal = fundMe.getOwner().balance;
        uint256 startingFundMeBal = address(fundMe).balance;
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        vm.stopPrank();
        uint256 endingFundMe = address(fundMe).balance;
        uint256 endingOwnerBal = fundMe.getOwner().balance;
        assertEq(endingFundMe, 0);
        assertEq(endingOwnerBal, startingFundMeBal+startingOwnerBal);
    }
    function testWithdrawFromMultipleFundersCheaper() public{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++)
        {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value : SEND_VALUE}();
        }
        uint256 startingOwnerBal = fundMe.getOwner().balance;
        uint256 startingFundMeBal = address(fundMe).balance;
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawCheaper();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        vm.stopPrank();
        uint256 endingFundMe = address(fundMe).balance;
        uint256 endingOwnerBal = fundMe.getOwner().balance;
        assertEq(endingFundMe, 0);
        assertEq(endingOwnerBal, startingFundMeBal+startingOwnerBal);
    }
} 