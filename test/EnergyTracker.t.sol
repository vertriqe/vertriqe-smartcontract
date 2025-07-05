// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
        string memory deviceType = "solar_panel";

        energyTracker.registerDevice(deviceId, deviceType);
        EnergyTracker.Device memory device = energyTracker.getDeviceInfo(deviceId);

        assertEq(device.deviceId, deviceId);
        assertEq(device.deviceType, deviceType);
        assertEq(device.owner, owner);
        assertTrue(device.isActive);
    }

    function test_RegisterDeviceFailsOnDuplicate() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId, "solar_panel");
        
        vm.expectRevert("Device already registered");
        energyTracker.registerDevice(deviceId, "solar_panel");
    }

    function test_RecordEnergyUsage() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId, "solar_panel");
        energyTracker.recordEnergyUsage(
            deviceId,
            100,
            "smart_meter",
            "{'temperature': 25}"
        );

        uint256 today = block.timestamp - (block.timestamp % 86400);
        EnergyTracker.EnergyData[] memory data = energyTracker.getDeviceEnergyData(deviceId, today, today);
        
        assertEq(data[0].energyUsage, 100);
        assertEq(data[0].dataSource, "smart_meter");
    }

    function test_RecordEnergyUsageFailsForNonOwner() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId, "solar_panel");
        
        vm.prank(otherAccount);
        vm.expectRevert("Not device owner");
        energyTracker.recordEnergyUsage(
            deviceId,
            100,
            "smart_meter",
            "{'temperature': 25}"
        );
    }

    function test_GetMonthlyAggregate() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId, "solar_panel");
        energyTracker.recordEnergyUsage(deviceId, 100, "smart_meter", "{}");

        uint256 currentMonth = energyTracker.getCurrentMonthTimestamp();
        EnergyTracker.MonthlyAggregate memory monthlyData = energyTracker.getMonthlyAggregate(deviceId, currentMonth);
        
        assertEq(monthlyData.totalEnergyUsage, 100);
        assertEq(monthlyData.daysRecorded, 1);
    }

    function test_GetDeviceInfoFailsForNonExistentDevice() public {
        vm.expectRevert("Device not found");
        energyTracker.getDeviceInfo("nonexistent");
    }

    function test_CleanupOldDataWithValidBatchSize() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId, "solar_panel");
        energyTracker.recordEnergyUsage(deviceId, 100, "smart_meter", "{}");

        // Should not revert with valid batch size
        energyTracker.cleanupOldData(deviceId, 10);
    }

    function test_CleanupOldDataFailsWithInvalidBatchSize() public {
        string memory deviceId = "device1";
        
        energyTracker.registerDevice(deviceId, "solar_panel");
        
        vm.expectRevert("Invalid batch size");
        energyTracker.cleanupOldData(deviceId, 0);

        vm.expectRevert("Invalid batch size");
        energyTracker.cleanupOldData(deviceId, 101);
    }
}