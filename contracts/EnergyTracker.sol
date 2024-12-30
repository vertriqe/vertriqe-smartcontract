// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract EnergyTracker {
    struct Device {
        string deviceId;
        string deviceType;
        address owner;
        bool isActive;
        uint256 registrationTime;
    }

    struct EnergyData {
        uint256 timestamp;
        uint256 energyUsage;
        string dataSource;
        string metadata;
    }

    struct MonthlyAggregate {
        uint256 monthTimestamp;  // First day of month timestamp
        uint256 totalEnergyUsage;
        uint256 daysRecorded;
    }

    mapping(string => Device) public devices;
    mapping(string => mapping(uint256 => EnergyData)) public deviceDailyData; // deviceId => date => data
    mapping(string => mapping(uint256 => MonthlyAggregate)) public deviceMonthlyData; // deviceId => monthTimestamp => data
    uint256 public constant DATA_RETENTION_DAYS = 30; // Keep detailed data for 30 days
    
    event DeviceRegistered(string deviceId, string deviceType, address owner);
    event EnergyDataRecorded(string deviceId, uint256 energyUsage, uint256 timestamp);

    modifier onlyDeviceOwner(string memory deviceId) {
        require(devices[deviceId].owner == msg.sender, "Not device owner");
        _;
    }

    function registerDevice(string memory deviceId, string memory deviceType) public {
        require(devices[deviceId].owner == address(0), "Device already registered");
        
        devices[deviceId] = Device({
            deviceId: deviceId,
            deviceType: deviceType,
            owner: msg.sender,
            isActive: true,
            registrationTime: block.timestamp
        });

        emit DeviceRegistered(deviceId, deviceType, msg.sender);
    }

    function recordEnergyUsage(
        string memory deviceId,
        uint256 energyUsage,
        string memory dataSource,
        string memory metadata
    ) public onlyDeviceOwner(deviceId) {
        require(devices[deviceId].isActive, "Device is not active");

        uint256 today = block.timestamp - (block.timestamp % 86400);
        uint256 currentMonth = today - (today % (86400 * 30));

        // Store daily data
        deviceDailyData[deviceId][today] = EnergyData({
            timestamp: block.timestamp,
            energyUsage: energyUsage,
            dataSource: dataSource,
            metadata: metadata
        });

        // Update monthly aggregate
        MonthlyAggregate storage monthlyData = deviceMonthlyData[deviceId][currentMonth];
        if (monthlyData.monthTimestamp == 0) {
            deviceMonthlyData[deviceId][currentMonth] = MonthlyAggregate({
                monthTimestamp: currentMonth,
                totalEnergyUsage: energyUsage,
                daysRecorded: 1
            });
        } else {
            monthlyData.totalEnergyUsage += energyUsage;
            monthlyData.daysRecorded++;
        }

        emit EnergyDataRecorded(deviceId, energyUsage, block.timestamp);
    }

    function getDeviceEnergyData(string memory deviceId, uint256 fromDate, uint256 toDate) 
        public view returns (EnergyData[] memory) {
        require(toDate >= fromDate, "Invalid date range");
        
        uint256 dayCount = (toDate - fromDate) / 86400 + 1;
        EnergyData[] memory result = new EnergyData[](dayCount);
        
        for (uint256 i = 0; i < dayCount; i++) {
            uint256 day = fromDate + (i * 86400);
            result[i] = deviceDailyData[deviceId][day];
        }
        
        return result;
    }

    function getMonthlyAggregate(string memory deviceId, uint256 monthTimestamp) 
        public view returns (MonthlyAggregate memory) {
        return deviceMonthlyData[deviceId][monthTimestamp];
    }

    function getMonthlyAggregates(
        string memory deviceId, 
        uint256 fromMonth, 
        uint256 toMonth
    ) public view returns (MonthlyAggregate[] memory) {
        require(toMonth >= fromMonth, "Invalid date range");
        
        uint256 monthCount = ((toMonth - fromMonth) / (86400 * 30)) + 1;
        MonthlyAggregate[] memory aggregates = new MonthlyAggregate[](monthCount);
        
        for (uint256 i = 0; i < monthCount; i++) {
            uint256 monthTimestamp = fromMonth + (i * 86400 * 30);
            aggregates[i] = deviceMonthlyData[deviceId][monthTimestamp];
        }
        
        return aggregates;
    }

    function cleanupOldData(string memory deviceId) public onlyDeviceOwner(deviceId) {
        uint256 cutoffDate = block.timestamp - (DATA_RETENTION_DAYS * 86400);
        uint256 currentDay = block.timestamp - (block.timestamp % 86400);
        
        for (uint256 day = currentDay; day >= cutoffDate; day -= 86400) {
            delete deviceDailyData[deviceId][day];
        }
    }

    function getDeviceInfo(string memory deviceId) public view returns (Device memory) {
        require(devices[deviceId].owner != address(0), "Device not found");
        return devices[deviceId];
    }

}
