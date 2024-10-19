import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";


describe("FootballTicketBooking", function () {
  let FootballTicketBooking, FootballTicketBooking;
  let admin, user1, user2;
  const ticketPrice = ethers.utils.parseEther("0.05");

  beforeEach(async function () {
    [admin, user1, user2] = await ethers.getSigners();
    
    FootballTicketBooking = await ethers.getContractFactory("FootballTicketBooking");
    FootballTicketBooking = await FootballTicketBooking.deploy();
    await FootballTicketBooking.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right admin", async function () {
      expect(await FootballTicketBooking.admin()).to.equal(admin.address);
    });

    it("Should have the correct ticket price", async function () {
      expect(await FootballTicketBooking.ticketPrice()).to.equal(ticketPrice);
    });
  });

  describe("Ticket purchase", function () {
    it("Should allow user to purchase a ticket", async function () {
      await FootballTicketBooking.connect(user1).purchaseTicket(1, { value: ticketPrice });

      const ticket = await FootballTicketBooking.tickets(0);
      expect(ticket.owner).to.equal(user1.address);
      expect(ticket.matchId).to.equal(1);
      expect(ticket.isUsed).to.equal(false);
    });

    it("Should fail if incorrect Ether sent", async function () {
      await expect(
        FootballTicketBooking.connect(user1).purchaseTicket(1, { value: ethers.utils.parseEther("0.01") })
      ).to.be.revertedWithCustomError(FootballTicketBooking, "IncorrectEtherSent");
    });

    it("Should fail if match ID is invalid", async function () {
      await expect(
        FootballTicketBooking.connect(user1).purchaseTicket(0, { value: ticketPrice })
      ).to.be.revertedWithCustomError(FootballTicketBooking, "InvalidMatchId");
    });
  });

  describe("Ticket verification", function () {
    it("Should allow admin to verify a ticket", async function () {
      await FootballTicketBooking.connect(user1).purchaseTicket(1, { value: ticketPrice });

      await FootballTicketBooking.connect(admin).verifyTicket(0);

      const ticket = await FootballTicketBooking.tickets(0);
      expect(ticket.isUsed).to.equal(true);
    });

    it("Should fail if ticket is already used", async function () {
      await FootballTicketBooking.connect(user1).purchaseTicket(1, { value: ticketPrice });
      await FootballTicketBooking.connect(admin).verifyTicket(0);

      await expect(FootballTicketBooking.connect(admin).verifyTicket(0))
        .to.be.revertedWithCustomError(FootballTicketBooking, "TicketAlreadyUsed");
    });

    it("Should fail if non-admin tries to verify ticket", async function () {
      await FootballTicketBooking.connect(user1).purchaseTicket(1, { value: ticketPrice });

      await expect(FootballTicketBooking.connect(user1).verifyTicket(0))
        .to.be.revertedWithCustomError(FootballTicketBooking, "NotAdmin");
    });
  });

  describe("Admin actions", function () {
    it("Should allow admin to set a new ticket price", async function () {
      const newPrice = ethers.utils.parseEther("0.1");
      await FootballTicketBooking.connect(admin).setTicketPrice(newPrice);

      expect(await FootballTicketBooking.ticketPrice()).to.equal(newPrice);
    });

    it("Should fail if non-admin tries to set a new ticket price", async function () {
      await expect(FootballTicketBooking.connect(user1).setTicketPrice(ticketPrice))
        .to.be.revertedWithCustomError(FootballTicketBooking, "NotAdmin");
    });

    it("Should allow admin to pause and unpause the contract", async function () {
      await FootballTicketBooking.connect(admin).pause();
      expect(await FootballTicketBooking.paused()).to.equal(true);

      await FootballTicketBooking.connect(admin).unpause();
      expect(await FootballTicketBooking.paused()).to.equal(false);
    });

    it("Should fail if non-admin tries to pause the contract", async function () {
      await expect(FootballTicketBooking.connect(user1).pause())
        .to.be.revertedWithCustomError(FootballTicketBooking, "NotAdmin");
    });

    it("Should prevent ticket purchase when contract is paused", async function () {
      await FootballTicketBooking.connect(admin).pause();
      await expect(FootballTicketBooking.connect(user1).purchaseTicket(1, { value: ticketPrice }))
        .to.be.revertedWithCustomError(FootballTicketBooking, "ContractIsPaused");
    });
  });

  describe("Withdraw funds", function () {
    it("Should allow admin to withdraw funds", async function () {
      await FootballTicketBooking.connect(user1).purchaseTicket(1, { value: ticketPrice });

      const initialAdminBalance = await ethers.provider.getBalance(admin.address);
      const contractBalance = await ethers.provider.getBalance(FootballTicketBooking.address);

      await FootballTicketBooking.connect(admin).withdrawFunds();

      const finalAdminBalance = await ethers.provider.getBalance(admin.address);
      expect(await ethers.provider.getBalance(FootballTicketBooking.address)).to.equal(0);
      expect(finalAdminBalance).to.be.gt(initialAdminBalance.add(contractBalance).sub(ethers.utils.parseEther("0.01"))); // account for gas costs
    });

    it("Should fail if there are no funds to withdraw", async function () {
      await expect(FootballTicketBooking.connect(admin).withdrawFunds())
        .to.be.revertedWithCustomError(FootballTicketBooking, "NoFundsToWithdraw");
    });
  });
});