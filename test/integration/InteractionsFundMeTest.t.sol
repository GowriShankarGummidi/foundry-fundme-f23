//SPDX-License-Identifier:Mit
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMeContract} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/IntegrationFundMe.s.sol";

contract FundMeTestIntegration is Test{
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
    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        console.log("iiiiiiiiii");
        console.log(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}