// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EnergyTracker} from "../src/EnergyTracker.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        EnergyTracker energyTracker = new EnergyTracker();
        
        console.log("EnergyTracker deployed at:", address(energyTracker));
        
        vm.stopBroadcast();
    }
}