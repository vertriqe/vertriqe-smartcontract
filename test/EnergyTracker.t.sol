// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {EnergyTracker} from "../src/EnergyTracker.sol";

contract EnergyTrackerTest is Test {
    EnergyTracker public energyTracker;
    address public owner;
    address public otherAccount;

    function setUp() public {
        energyTracker = new EnergyTracker();
        owner = address(this);
        otherAccount = address(0x1234);
        
        // Set timestamp to a reasonable value to avoid underflow
        vm.warp(1672531200); // Jan 1, 2023
    }

    function test_RegisterDevice() public {
        string memory deviceId = "device1";

        energyTracker.registerDevice(deviceId);
        EnergyTracker.Device memory device = energyTracker.getDevice(deviceId);

        assertEq(device.owner, owner);
        assertEq(device.regTime, block.timestamp);
    }

    function test_RegisterDeviceFailsOnDuplicate() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId);
        
        vm.expectRevert("Device already registered");
        energyTracker.registerDevice(deviceId);
    }

    function test_RecordEnergyUsage() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId);
        energyTracker.recordEnergyUsage(deviceId, 100);

        uint256 today = block.timestamp / 1 days;
        EnergyTracker.EnergyData memory data = energyTracker.getEnergyData(deviceId, today);
        
        assertEq(data.value, 100);
        assertEq(data.timestamp, block.timestamp);
    }

    function test_RecordEnergyUsageFailsForNonOwner() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId);
        
        vm.prank(otherAccount);
        vm.expectRevert("Not device owner");
        energyTracker.recordEnergyUsage(deviceId, 100);
    }

    function test_GetOwnerDevices() public {
        string memory deviceId1 = "device1";
        string memory deviceId2 = "device2";
        
        energyTracker.registerDevice(deviceId1);
        energyTracker.registerDevice(deviceId2);

        string[] memory devices = energyTracker.getOwnerDevices(owner);
        
        assertEq(devices.length, 2);
        assertEq(devices[0], deviceId1);
        assertEq(devices[1], deviceId2);
    }

    function test_DataRetentionCleanup() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId);
        
        // Record data for a specific day  
        uint256 oldDay = block.timestamp / 1 days;
        energyTracker.recordEnergyUsage(deviceId, 100);
        
        // Move forward exactly DATA_RETENTION_DAYS
        vm.warp(block.timestamp + energyTracker.DATA_RETENTION_DAYS() * 1 days);
        
        // Record new data, which should trigger cleanup of data at oldDay
        energyTracker.recordEnergyUsage(deviceId, 200);
        
        // Old data should be cleaned up (at exactly DATA_RETENTION_DAYS ago)
        EnergyTracker.EnergyData memory oldData = energyTracker.getEnergyData(deviceId, oldDay);
        assertEq(oldData.timestamp, 0);
        assertEq(oldData.value, 0);
        
        // New data should exist
        uint256 newDay = block.timestamp / 1 days;
        EnergyTracker.EnergyData memory newData = energyTracker.getEnergyData(deviceId, newDay);
        assertEq(newData.value, 200);
    }

    function test_EmptyDeviceReturnsZeroAddress() public {
        string memory deviceId = "nonexistent";
        
        EnergyTracker.Device memory device = energyTracker.getDevice(deviceId);
        assertEq(device.owner, address(0));
        assertEq(device.regTime, 0);
    }

    function test_EmptyEnergyDataReturnsZero() public {
        string memory deviceId = "device1";
        uint256 someDate = 12345;
        
        EnergyTracker.EnergyData memory data = energyTracker.getEnergyData(deviceId, someDate);
        assertEq(data.timestamp, 0);
        assertEq(data.value, 0);
    }
}