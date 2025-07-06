// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;
contract EnergyTracker {
    struct Device {
        address owner;
        uint256 regTime;      // 註冊時間
    }
    
    struct EnergyData {
        uint64 timestamp;
        uint32 value;         // 能源使用量
    }
    
    // 設備ID -> 設備資訊
    mapping(string => Device) public devices;
    
    // 設備ID -> 日期 -> 能源數據
    mapping(string => mapping(uint256 => EnergyData)) public deviceDailyData;
    
    // 擁有者 -> 設備ID列表
    mapping(address => string[]) public ownerDevices;
    
    // 事件
    event DeviceRegistered(string indexed deviceId, address indexed owner, uint256 regTime);
    event EnergyRecorded(string indexed deviceId, uint32 value, uint64 timestamp);
    
    // 註冊設備
    function registerDevice(string memory deviceId) public {
        require(devices[deviceId].owner == address(0), "Device already registered");
        
        devices[deviceId] = Device({
            owner: msg.sender,
            regTime: block.timestamp
        });
        
        ownerDevices[msg.sender].push(deviceId);
        
        emit DeviceRegistered(deviceId, msg.sender, block.timestamp);
    }
    
    uint256 public constant DATA_RETENTION_DAYS = 365; // 只保留一年數據

    function recordEnergyUsage(string memory deviceId, uint32 value) public {
        require(devices[deviceId].owner == msg.sender, "Not device owner");
        
        uint256 today = block.timestamp / 1 days;
        
        // 清理舊數據
        if (deviceDailyData[deviceId][today - DATA_RETENTION_DAYS].timestamp != 0) {
            delete deviceDailyData[deviceId][today - DATA_RETENTION_DAYS];
        }
        
        deviceDailyData[deviceId][today] = EnergyData({
            timestamp: uint64(block.timestamp),
            value: value
        });
    }
    
    // 查詢設備資訊
    function getDevice(string memory deviceId) 
        public view returns (Device memory) {
        return devices[deviceId];
    }
    
    // 查詢能源數據
    function getEnergyData(string memory deviceId, uint256 date) 
        public view returns (EnergyData memory) {
        return deviceDailyData[deviceId][date];
    }
    
    // 查詢用戶擁有的設備
    function getOwnerDevices(address owner) 
        public view returns (string[] memory) {
        return ownerDevices[owner];
    }
}