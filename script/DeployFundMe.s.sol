//SPDX-License-Identifier : MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMeContract is Script{
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethAddress = helperConfig.activeNetworkConfig();
    
        FundMe fundMe = new FundMe(ethAddress);
        //FundMe fundMe = new FundMe();
    
        return fundMe;
    }
}