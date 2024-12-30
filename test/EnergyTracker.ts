import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("EnergyTracker", function () {
  async function deployEnergyTrackerFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners();
    const EnergyTracker = await hre.ethers.getContractFactory("EnergyTracker");
    const energyTracker = await EnergyTracker.deploy();
    
    return { energyTracker, owner, otherAccount };
  }

  describe("Device Registration", function () {
    it("Should register a new device", async function () {
      const { energyTracker, owner } = await loadFixture(deployEnergyTrackerFixture);
      const deviceId = "device1";
      const deviceType = "solar_panel";

      await energyTracker.registerDevice(deviceId, deviceType);
      const device = await energyTracker.getDeviceInfo(deviceId);

      expect(device.deviceId).to.equal(deviceId);
      expect(device.deviceType).to.equal(deviceType);
      expect(device.owner).to.equal(owner.address);
      expect(device.isActive).to.be.true;
    });

    it("Should fail to register duplicate device", async function () {
      const { energyTracker } = await loadFixture(deployEnergyTrackerFixture);
      const deviceId = "device1";
      
      await energyTracker.registerDevice(deviceId, "solar_panel");
      await expect(
        energyTracker.registerDevice(deviceId, "solar_panel")
      ).to.be.revertedWith("Device already registered");
    });
  });

  describe("Energy Usage Recording", function () {
    it("Should record energy usage data", async function () {
      const { energyTracker } = await loadFixture(deployEnergyTrackerFixture);
      const deviceId = "device1";
      
      await energyTracker.registerDevice(deviceId, "solar_panel");
      await energyTracker.recordEnergyUsage(
        deviceId,
        100,
        "smart_meter",
        "{'temperature': 25}"
      );

      const today = Math.floor(Date.now() / 1000) - (Math.floor(Date.now() / 1000) % 86400);
      const data = await energyTracker.getDeviceEnergyData(deviceId, today, today);
      
      expect(data[0].energyUsage).to.equal(100);
      expect(data[0].dataSource).to.equal("smart_meter");
    });

    it("Should fail if non-owner tries to record data", async function () {
      const { energyTracker, otherAccount } = await loadFixture(deployEnergyTrackerFixture);
      const deviceId = "device1";
      
      await energyTracker.registerDevice(deviceId, "solar_panel");
      await expect(
        energyTracker.connect(otherAccount).recordEnergyUsage(
          deviceId,
          100,
          "smart_meter",
          "{'temperature': 25}"
        )
      ).to.be.revertedWith("Not device owner");
    });
  });

  describe("Data Retrieval", function () {
    it("Should retrieve monthly aggregates", async function () {
      const { energyTracker } = await loadFixture(deployEnergyTrackerFixture);
      const deviceId = "device1";
      
      await energyTracker.registerDevice(deviceId, "solar_panel");
      await energyTracker.recordEnergyUsage(deviceId, 100, "smart_meter", "{}");

      const currentMonth = Math.floor(Date.now() / 1000) - (Math.floor(Date.now() / 1000) % (86400 * 30));
      const monthlyData = await energyTracker.getMonthlyAggregate(deviceId, currentMonth);
      
      expect(monthlyData.totalEnergyUsage).to.equal(100);
      expect(monthlyData.daysRecorded).to.equal(1);
    });

    it("Should fail to get info for non-existent device", async function () {
      const { energyTracker } = await loadFixture(deployEnergyTrackerFixture);
      
      await expect(
        energyTracker.getDeviceInfo("nonexistent")
      ).to.be.revertedWith("Device not found");
    });
  });
});
