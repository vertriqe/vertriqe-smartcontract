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
    uint256 public constant DATA_RETENTION_DAYS = 366; // Keep detailed data for 366 days
    
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
        uint256 currentMonth = _getMonthTimestamp(block.timestamp);

        // Check if this is a new day for this device
        bool isNewDay = deviceDailyData[deviceId][today].timestamp == 0;

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
            if (isNewDay) {
                monthlyData.daysRecorded++;
            }
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
        
        // Calculate month count more accurately
        uint256 monthCount = 1;
        uint256 currentMonth = fromMonth;
        while (currentMonth < toMonth) {
            currentMonth = _getNextMonthTimestamp(currentMonth);
            monthCount++;
        }
        
        MonthlyAggregate[] memory aggregates = new MonthlyAggregate[](monthCount);
        currentMonth = fromMonth;
        
        for (uint256 i = 0; i < monthCount; i++) {
            aggregates[i] = deviceMonthlyData[deviceId][currentMonth];
            if (i < monthCount - 1) {
                currentMonth = _getNextMonthTimestamp(currentMonth);
            }
        }
        
        return aggregates;
    }

    function cleanupOldData(string memory deviceId, uint256 batchSize) public onlyDeviceOwner(deviceId) {
        require(batchSize > 0 && batchSize <= 100, "Invalid batch size");
        
        uint256 cutoffDate = block.timestamp - (DATA_RETENTION_DAYS * 86400);
        uint256 currentDay = block.timestamp - (block.timestamp % 86400);
        
        uint256 processed = 0;
        uint256 day = currentDay;
        
        // Process in batches to avoid gas limit issues
        while (processed < batchSize && day > cutoffDate) {
            if (deviceDailyData[deviceId][day].timestamp != 0) {
                delete deviceDailyData[deviceId][day];
            }
            day -= 86400;
            processed++;
        }
    }

    function getDeviceInfo(string memory deviceId) public view returns (Device memory) {
        require(devices[deviceId].owner != address(0), "Device not found");
        return devices[deviceId];
    }

    function getCurrentMonthTimestamp() public view returns (uint256) {
        return _getMonthTimestamp(block.timestamp);
    }

    function _getMonthTimestamp(uint256 timestamp) internal pure returns (uint256) {
        // Get the first day of the month
        uint256 year = _getYear(timestamp);
        uint256 month = _getMonth(timestamp);
        return _timestampFromDate(year, month, 1);
    }

    function _getNextMonthTimestamp(uint256 monthTimestamp) internal pure returns (uint256) {
        uint256 year = _getYear(monthTimestamp);
        uint256 month = _getMonth(monthTimestamp);
        
        if (month == 12) {
            return _timestampFromDate(year + 1, 1, 1);
        } else {
            return _timestampFromDate(year, month + 1, 1);
        }
    }

    function _getYear(uint256 timestamp) internal pure returns (uint256) {
        uint256 secondsPerYear = 365 days;
        uint256 year = 1970 + timestamp / secondsPerYear;
        
        // Approximate adjustment for leap years
        uint256 leapAdjustment = (year - 1972) / 4;
        year = 1970 + (timestamp + leapAdjustment * 1 days) / secondsPerYear;
        
        return year;
    }

    function _getMonth(uint256 timestamp) internal pure returns (uint256) {
        uint256 year = _getYear(timestamp);
        uint256 yearStart = _timestampFromDate(year, 1, 1);
        uint256 dayOfYear = (timestamp - yearStart) / 86400 + 1;
        
        // Simplified month calculation (approximation)
        if (dayOfYear <= 31) return 1;
        if (dayOfYear <= 59) return 2;
        if (dayOfYear <= 90) return 3;
        if (dayOfYear <= 120) return 4;
        if (dayOfYear <= 151) return 5;
        if (dayOfYear <= 181) return 6;
        if (dayOfYear <= 212) return 7;
        if (dayOfYear <= 243) return 8;
        if (dayOfYear <= 273) return 9;
        if (dayOfYear <= 304) return 10;
        if (dayOfYear <= 334) return 11;
        return 12;
    }

    function _timestampFromDate(uint256 year, uint256 month, uint256 day) internal pure returns (uint256) {
        // Simplified calculation - approximation for first day of month
        uint256 timestamp = (year - 1970) * 365 days;
        
        // Add leap year days
        timestamp += ((year - 1972) / 4) * 1 days;
        
        // Add month days (approximation)
        uint256[12] memory monthDays = [uint256(0), 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
        if (month > 1) {
            timestamp += monthDays[month - 1] * 86400;
        }
        
        // Add day
        timestamp += (day - 1) * 86400;
        
        return timestamp;
    }

}
